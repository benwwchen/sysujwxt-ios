//
//  JwxtApiClient.swift
//  SYSUJwxt
//
//  Created by benwwchen on 2017/8/17.
//  Copyright © 2017年 benwwchen. All rights reserved.
//

import Foundation
import Kanna

class JwxtApiClient {
    
    //MARK: Properties
    var netId: String = ""
    var password: String = ""
    var studentNumber: Int = 0
    var grade: Int = 0
    var schoolId: String = ""
    var isLogin: Bool = false
    
    let session = URLSession.shared
    
    
    //MARK: Constants
    struct Paths {
        static let BaseUrl = "http://uems.sysu.edu.cn/jwxt"
        static let RealLoginUrl = "https://cas.sysu.edu.cn/cas/login?service=http%3A%2F%2Fuems.sysu.edu.cn%2Fjwxt%2FcasLogin"
        static let CasLoginBaseUrl = "https://cas.sysu.edu.cn"
        static let CasLoginPath = "/casLogin"
        
        static let InfoPath = "/xscjcxAction/xscjcxAction.action?method=judgeStu"
        static let CourseListPath = "/KcbcxAction/KcbcxAction.action?method=getList"
        static let ScoreListPath = "/xscjcxAction/xscjcxAction.action?method=getKccjList"
        static let GPAPath = "/xscjcxAction/xscjcxAction.action?method=getAllJd"
        static let CreditPath = "/xscjcxAction/xscjcxAction.action?method=getAllXf"
        static let TotalCreditPath = "xscjcxAction/xscjcxAction.action?method=getZyxf"
    }
    
    struct Messages {
        static let LoginPageError = "登陆出错，无法访问登陆页"
        static let LoginError = "登陆出错，无法登陆"
        static let LoginSuccess = "登陆成功"
        static let GetCoursesError = "获取课程列表失败"
        static let Success = "成功"
    }
    
    enum JwxtApiError: Error {
        case badResponse
    }
    
    //MARK: Initialization
    
    private init() {
        _ = getSavedPassword()
    }
    
    // MARK: Shared Instance
    
    static let shared = JwxtApiClient()
    
    //MARK: Methods
    
    // retrieve login page
    func login(completion: @escaping (_ success: Bool, _ object: Any?) -> ()) {
        
        let request = clientURLRequest(method: "GET", urlString: Paths.BaseUrl + Paths.CasLoginPath)
        
        customDataTask(request: request) { (success, object) in
            
            // parse data and do real login in background
            DispatchQueue.global(qos: .userInitiated).async {

                if success {
                    // 302 redirected to
                    // https://cas.sysu.edu.cn/cas/login?service=http%3A%2F%2Fuems.sysu.edu.cn%2Fjwxt%2FcasLogin
                    
                    // now get the login form from the html
                    var ltValue: String = ""
                    var executionValue: String = ""
                    var formAction: String = ""
                    
                    if let doc = HTML(html: object as! Data, encoding: String.Encoding.utf8) {
                        
                        if let lt = doc.xpath("//input[@name='lt']").first?["value"]  {
                            ltValue = lt
                        }
                        
                        if let execution = doc.xpath("//input[@name='execution']").first?["value"]  {
                            executionValue = execution
                        }
                        
                        if let action = doc.xpath("//form[@id='fm1']").first?["action"]  {
                            formAction = action
                        }
                    }
                    
                    let loginForm = [
                        "username": self.netId,
                        "password": self.password,
                        "lt": ltValue,
                        "execution": executionValue,
                        "_eventId": "submit",
                        "submit": "登陆"
                    ]
                    
                    // do real login
                    self.realLogin(form: loginForm, formAction: formAction, completion: completion)
                    
                } else {
                    let message = Messages.LoginPageError
                    print("\(message)")
                }
            }
        }
    }
    
    private func realLogin(form: Dictionary<String, String>?, formAction: String, completion: @escaping (_ success: Bool, _ object: Any?) -> ()) {
        
        var request = clientURLRequest(method: "POST", urlString: Paths.CasLoginBaseUrl + formAction, params: form as Dictionary<String, AnyObject>?)
        
        request.setValue("https://cas.sysu.edu.cn", forHTTPHeaderField: "Origin")
        request.setValue("https://cas.sysu.edu.cn/cas/login?service=http%3A%2F%2Fuems.sysu.edu.cn%2Fjwxt%2FcasLogin", forHTTPHeaderField: "Referer")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("1", forHTTPHeaderField: "Upgrade-Insecure-Requests")
        request.setValue("max-age=0", forHTTPHeaderField: "Cache-Control")
        request.setValue("zh,zh-CN;q=0.8,zh-TW;q=0.6,en-US;q=0.4,en;q=0.2", forHTTPHeaderField: "Accept-Language")
        
        customDataTask(request: request) { (success, object) in
            
            var message = Messages.LoginSuccess
            
            if success {
                
                self.getInfo(completion: completion)
                
            } else {
                // login fail
                message = Messages.LoginError
                completion(false, message)
                
            }
            
        }
    }
    
    func getInfo(completion: @escaping (_ success: Bool, _ object: Any?) -> ()) {
        let request = clientURLRequest(method: "POST", urlString: Paths.BaseUrl + Paths.InfoPath, data: "{header:{\"code\": -100, \"message\": {\"title\": \"\", \"detail\": \"\"}},body:{dataStores:{},parameters:{\"args\": [], \"responseParam\": \"result\"}}}", isUemsJwxtApi: true)
        
        customDataTask(request: request) { (success, object) in
            
            print ("\(String(describing: NSString(data: object as! Data, encoding: String.Encoding.utf8.rawValue)))")
            
            var message: String = Messages.LoginSuccess
            var isSuccess: Bool = true
            
            do {
                
                if success, let string = String(data: object as! Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                    
                    if let result = string.matchingStrings(regex: "\\{result:\"(.*)\"\\}").first?[1] {
                        
                        self.studentNumber = Int(result.components(separatedBy: ",")[0])!
                        self.grade = Int(result.components(separatedBy: ",")[1])!
                        self.schoolId = result.components(separatedBy: ",")[2]
                        self.isLogin = true
                        self.savePassword()
                        
                    } else {
                        throw JwxtApiError.badResponse
                    }
                    
                }
                
            } catch {
                
                print("\(error)")
                isSuccess = false
                message = Messages.LoginError
                
            }
            
            DispatchQueue.main.async {
                completion(isSuccess, message)
            }
        }
    }
    
    func getCourseList(year: Int, term: Int, completion: @escaping (_ success: Bool, _ object: Any?) -> ()) {
        
        let yearArg = "\(year)-\(year+1)"
        
        let request = clientURLRequest(method: "POST", urlString: Paths.BaseUrl + Paths.CourseListPath, data: "{header:{\"code\": -100, \"message\": {\"title\": \"\", \"detail\": \"\"}},body:{dataStores:{},parameters:{\"args\": [\"\(term)\", \"\(yearArg)\"], \"responseParam\": \"rs\"}}}", isUemsJwxtApi: true)
        
        customDataTask(request: request) { (success, object) in
            
            //print ("\(String(describing: NSString(data: object as! Data, encoding: String.Encoding.utf8.rawValue)))")
            
            var courses = [Course]()
            var message: String = Messages.Success
            var isSuccess: Bool = true
            
            do {
                
                if success, let string = String(data: object as! Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                    
                    if let result = string.matchingStrings(regex: "\\{rs:\"(.*)\"\\}").first?[1] {
                        
                        if let doc = HTML(html: result, encoding: .utf8) {
                            print(doc.title)
                            
                            // Search for nodes by XPath
                            for tr in doc.xpath("//tr") {
                                let tds = tr.xpath("./td")
                                for (index, td) in tds.enumerated() {
                                    if td["rowspan"] != nil,
                                        var contents = td.innerHTML?.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "<br>") {
                                        
                                        let courseTime = contents[2].replacingOccurrences(of: "节", with: "").components(separatedBy: "-").map({ Int($0)! })
                                        
                                        var offset = 0
                                        if tds.count < 8 {
                                            for course in courses {
                                                if course.day <= index + offset &&
                                                    course.startTime < courseTime[0] &&
                                                    course.endTime >= courseTime[0] {
                                                    offset += 1
                                                }
                                            }
                                        }
                                        
                                        courses.append(Course.init(name: contents[0], location: contents[1], day: index + offset, startTime: courseTime[0], endTime: courseTime[1], duration: contents[3]))
                                        
                                        print("\(contents)")
                                    }
                                }
                            }
                        }
                        
                        
                        
                    } else {
                        throw JwxtApiError.badResponse
                    }
                    
                }
                
            } catch {
                
                print("\(error)")
                isSuccess = false
                message = Messages.GetCoursesError
                
            }
            
            if isSuccess {
                completion(isSuccess, courses)
            } else {
                completion(isSuccess, message)
            }
            
        }
    }
    
    func getScoreList(year: Int, term: Int, completion: @escaping (_ success: Bool, _ object: Any?) -> ()) {
        
        let yearArg = "\(year)-\(year+1)"
        
        let request = clientURLRequest(method: "POST", urlString: Paths.BaseUrl + Paths.ScoreListPath, data: "{header:{\"code\": -100, \"message\": {\"title\": \"\", \"detail\": \"\"}},body:{dataStores:{kccjStore:{rowSet:{\"primary\":[],\"filter\":[],\"delete\":[]},name:\"kccjStore\",pageNumber:1,pageSize:10,recordCount:0,rowSetName:\"pojo_com.neusoft.education.sysu.xscj.xscjcx.model.KccjModel\",order:\"t.xn, t.xq, t.kch, t.bzw\"}},parameters:{\"kccjStore-params\": [{\"name\": \"Filter_t.pylbm_0.7607312996540416\", \"type\": \"String\", \"value\": \"'01'\", \"condition\": \" = \", \"property\": \"t.pylbm\"}, {\"name\": \"Filter_t.xn_0.7704413492958447\", \"type\": \"String\", \"value\": \"'\(yearArg)'\", \"condition\": \" = \", \"property\": \"t.xn\"}, {\"name\": \"Filter_t.xq_0.40025491171181043\", \"type\": \"String\", \"value\": \"'\(term)'\", \"condition\": \" = \", \"property\": \"t.xq\"}], \"args\": [\"student\"]}}}", isUemsJwxtApi: true)
        
        customDataTask(request: request) { (success, object) in
            
            print ("\(String(describing: NSString(data: object as! Data, encoding: String.Encoding.utf8.rawValue)))")
            
            var grades = [Grade]()
            var message: String = Messages.Success
            var isSuccess: Bool = true
            
            do {
                
                if success, let string = String(data: object as! Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                    
                    guard let resultData = string.matchingStrings(regex: "\\{primary:(\\[.*\\])\\}").first?[1].data(using: .utf8) else {
                        throw JwxtApiError.badResponse
                    }
                    
                    // now we got the correct JSON format
                    guard let json = (try? JSONSerialization.jsonObject(with: resultData, options: [])) as? [Any] else {
                        throw JwxtApiError.badResponse
                    }
                    
                    print("\(json)")
                    
                    for object in json {
                        if let dict = object as? [String : Any],
                            let grade = Grade.init(json: dict) {
                            grades.append(grade)
                        }
                    }
                    
                }
                
            } catch {
                
                print("\(error)")
                isSuccess = false
                message = Messages.GetCoursesError
                
            }
            
            if isSuccess {
                completion(isSuccess, grades)
            } else {
                completion(isSuccess, message)
            }
        }
    }
    
    func getGPA(year: Int = 0, term: Int = 0, isGetAll: Bool = false, completion: @escaping (_ success: Bool, _ object: Any?) -> ()) {
        
        let data: String
        
        if isGetAll {
            data = "{header:{\"code\": -100, \"message\": {\"title\": \"\", \"detail\": \"\"}},body:{dataStores:{allJdStore:{rowSet:{\"primary\":[],\"filter\":[],\"delete\":[]},name:\"allJdStore\",pageNumber:1,pageSize:2147483647,recordCount:0,rowSetName:\"pojo_com.neusoft.education.sysu.djks.ksgl.model.TwoColumnModel\"}},parameters:{\"args\": [\"\(self.studentNumber)\", \"\", \"\", \"\"]}}}"
        } else {
            data = "{header:{\"code\": -100, \"message\": {\"title\": \"\", \"detail\": \"\"}},body:{dataStores:{jdStore:{rowSet:{\"primary\":[],\"filter\":[],\"delete\":[]},name:\"jdStore\",pageNumber:1,pageSize:0,recordCount:0,rowSetName:\"pojo_com.neusoft.education.sysu.djks.ksgl.model.TwoColumnModel\"}},parameters:{\"args\": [\"\(self.studentNumber)\", \"\(year)\", \"\(term)\", \"\"]}}}"
        }
        
        let request = clientURLRequest(method: "POST", urlString: Paths.BaseUrl + Paths.GPAPath, data: data, isUemsJwxtApi: true)
        
        customDataTask(request: request) { (success, object) in
            
            print ("\(String(describing: NSString(data: object as! Data, encoding: String.Encoding.utf8.rawValue)))")
            
            var gpas = [String: String]()
            var message: String = Messages.Success
            var isSuccess: Bool = true
            
            do {
                
                if success, let string = String(data: object as! Data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                    
                    guard let resultData = string.matchingStrings(regex: "\\{primary:(\\[.*\\])\\}").first?[1].data(using: .utf8) else {
                        throw JwxtApiError.badResponse
                    }
                    
                    guard let json = (try? JSONSerialization.jsonObject(with: resultData, options: [])) as? [Any] else {
                        throw JwxtApiError.badResponse
                    }
                        
                    print("\(json)")
                        
                    for object in json {
                        if let dict = object as? [String : String],
                            let key = dict["oneColumn"],
                            let value = dict["twoColumn"] {
                            gpas[key] = value
                        }
                    }
                    
                }
                
            } catch {
                
                print("\(error)")
                isSuccess = false
                message = Messages.GetCoursesError
                
            }
            
            if isSuccess {
                completion(isSuccess, gpas)
            } else {
                completion(isSuccess, message)
            }
        }
    }
    
    
    //MARK: Utils
    private func customDataTask(request: URLRequest, completion: @escaping (_ success: Bool, _ object: Any?) -> ()) {
        print("\(String(describing: request.url))")
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    completion(true, data)
                } else {
                    completion(false, data)
                }
            }
            }.resume()
    }
    
    private func jsonDataTask(request: URLRequest, completion: @escaping (_ success: Bool, _ object: Any?) -> ()) {
        
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    completion(true, json)
                } else {
                    completion(false, json)
                }
            }
            }.resume()
    }
    
    private func clientURLRequest(method: String, urlString: String, params: Dictionary<String, AnyObject>? = nil, data: String? = nil, isUemsJwxtApi: Bool = false) -> URLRequest {
        
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = method
        
        if let params = params {
            var paramString = ""
            for (key, value) in params {
                let escapedKey = (key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.replacingOccurrences(of: "+", with: "%2B"))!
                let escapedValue = (value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.replacingOccurrences(of: "+", with: "%2B"))!
                paramString += "\(escapedKey)=\(escapedValue)&"
            }
            
            request.httpBody = paramString.data(using: String.Encoding.utf8)
        }
        
        if let data = data {
            request.httpBody = data.data(using: String.Encoding.utf8)
            print("\(String(describing: data))")
        }
        
        if isUemsJwxtApi {
            // set headers for uems.sysu.edu.cn JSON API
            request.setValue("*/*", forHTTPHeaderField: "Accept")
            request.setValue("true", forHTTPHeaderField: "ajaxRequest")
            request.setValue("unieap", forHTTPHeaderField: "render")
            request.setValue("unieap", forHTTPHeaderField: "__clientType")
            request.setValue("null", forHTTPHeaderField: "workitemid")
            request.setValue("null", forHTTPHeaderField: "resourceid")
            request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        }
        
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.90 Safari/537.36", forHTTPHeaderField: "User-Agent")
        
        return request
    }
    
    // MARK: Session Persist
    func savePassword() {
        // Saving netId into UserDefaults
        UserDefaults.standard.set(self.netId, forKey: "netId")
        // Saving password into Keychain
        let passwordData: NSData = NSKeyedArchiver.archivedData(withRootObject: self.password) as NSData
        let userAccount = self.netId
        let identifier = "sysujwxt"
        let keychainQuery: [NSString: NSObject] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: userAccount as NSObject,
            kSecAttrService: identifier as NSObject,
            kSecValueData: passwordData]
        SecItemDelete(keychainQuery as CFDictionary) //Trying to delete the item from Keychaing just in case it already exists there
        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil)
        if (status == errSecSuccess) {
            print("Cookies succesfully saved into Keychain")
        }
    }
    
    func getSavedPassword() -> Bool {
        // Getting netId from UserDefaults
        guard let netId = UserDefaults.standard.string(forKey: "netId") else {
            return false
        }
        self.netId = netId
        // Getting password from Keychain
        let identifier = "sysujwxt"
        let keychainQueryForPassword: [NSString: NSObject] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: identifier as NSObject,
            kSecAttrAccount: self.netId as NSObject,
            kSecReturnData: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne]
        var rawResultForPassword: AnyObject?
        let status: OSStatus = SecItemCopyMatching(keychainQueryForPassword as CFDictionary, &rawResultForPassword)
        if (status == errSecSuccess) {
            let retrievedData = rawResultForPassword as? NSData
            if let unwrappedData = retrievedData {
                if let password = NSKeyedUnarchiver.unarchiveObject(with: unwrappedData as Data) as? String {
                    self.password = password
                    return true
                }
            }
        }
        return false
    }
    
}

extension String {
    func matchingStrings(regex: String) -> [[String]] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = self as NSString
            let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
            return results.map { result in
                (0..<result.numberOfRanges).map { result.rangeAt($0).location != NSNotFound
                    ? nsString.substring(with: result.rangeAt($0))
                    : ""
                }
            }
        } catch {
            print("\(error)")
        }
        return []
    }
    
}


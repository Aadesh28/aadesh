

import UIKit
import UserNotifications

class ViewController: UIViewController , UITableViewDataSource , UITableViewDelegate
{
    
    var mondayArray = Array<Monday>()
    var wednesdyArray = Array<Wednesday>()
    var thursdayArray = Array<Thursday>()
    var week_diet_data : Week_diet_data?
    
    @IBOutlet weak var tableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
      if section == 0
      {
        return (self.week_diet_data?.monday?.count) ?? 0
      }
        
      if section == 1
       {
            return (self.week_diet_data?.wednesday?.count) ?? 0
       }

       if section == 2
        {
            return (self.week_diet_data?.thursday?.count) ?? 0
        }

      return 0
     }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
      return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if section == 0
        {
            
            return "Monday"
        }
        
        if section == 1
        {
            
            return "Wednesday"
        }
        
        if section == 2
        {
            
            return "Thursday"
        }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.section == 0
        {
            let obj = week_diet_data?.monday![indexPath.row]
            cell.textLabel?.text = obj?.food
            cell.detailTextLabel?.text = obj?.meal_time
            return cell
        }
        
        if indexPath.section == 1
        {
            let obj = week_diet_data?.wednesday![indexPath.row]
            cell.textLabel?.text = obj?.food
            cell.detailTextLabel?.text = obj?.meal_time
            return cell
        }
        
        if indexPath.section == 2
        {
            let obj = week_diet_data?.thursday![indexPath.row]
            cell.textLabel?.text = obj?.food
            cell.detailTextLabel?.text = obj?.meal_time
            return cell
        }
        return cell
    }
    
    func notify()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
        { (success, error) in
            if success {
                print("Permission Granted")
                let notification = UNMutableNotificationContent()
                notification.title = "Reminder"
                notification.subtitle = "5 minutes to go"
                notification.body = "It's almost time for your next meal, take it on time"
                let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                let request = UNNotificationRequest(identifier: "notification1", content: notification, trigger: notificationTrigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
         }
            else
            {
                print("There was a problem!")
            }
        }
    }

    
    
    
    
    
    /*   FOR NOW AS SERVER IS NOT RESPONDING WITH THE CORRECT DATE TIME FORMAT ,
     So I HAVE CONSIDERED TIME AS STRING AND COMPARED IT WITH CURRENT TIME OF THE DEVICE
     THEN COMPARED CURRENT TIME WITH SERVER TIME .     */
 
    
    
    
    var globalhr = ""
    
    @objc func keepcheckingtime()
    {
        let hh = (Calendar.current.component(.hour, from: Date()))
        let mm = (Calendar.current.component(.minute, from: Date()))
        let ss = (Calendar.current.component(.second, from: Date()))
        print(hh,":", mm,":", ss)
        globalhr = "0" + String(hh) + ":" + String(mm) + "0"
        print("keepcheckingtime")
        functionalMealReminder()
    }
    
    func functionalMealReminder()
    {
        let mon =  self.mondayArray[0].meal_time
        if mon == self.globalhr
        {
            print("meal time at \(mon ?? "")")
            let alert = UIAlertController(title: "REMINDER !!", message: "5 minutes to go for your next meal, take it on time", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Alright", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
        
/*
         let current_time = x
         let server_time = y
         let date = server_time.addingTimeInterval(5.0 * 60.0)
         if server_time - current_time == 5
         {
            show alert
         }
 */
        
    
    
   
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(keepcheckingtime), userInfo: nil, repeats: true)
       
        
        notify()
        parseJSON()
    }
    
    func parseJSON ()
    {
        let url = URL(string: "https://naviadoctors.com/dummy/")
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error ) in
            
            guard error == nil else
            {
                print("returned error")
                return
            }
            if error != nil
            {
                
            }
            else
            {
                print("returned error")
            }
            
            guard let content = data else {
                
                print("No data")
                return
            }
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                print("Not containing JSON")
                return
            }
            do
            {
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(Json4Swift_Base.self, from: data!)
                print(responseModel.week_diet_data)
                print("monday data >>>>>")
                print(responseModel.week_diet_data?.monday)
               self.week_diet_data = responseModel.week_diet_data
                self.mondayArray = (responseModel.week_diet_data?.monday)!
                DispatchQueue.main.async
                {
                    self.tableView.reloadData()
                }
            }
            catch{}
            
        }; task.resume()
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}


func getCurrentDate()-> Date {
    var now = Date()
    var nowComponents = DateComponents()
    let calendar = Calendar.current
    nowComponents.year = Calendar.current.component(.year, from: now)
    nowComponents.month = Calendar.current.component(.month, from: now)
    nowComponents.day = Calendar.current.component(.day, from: now)
    nowComponents.hour = Calendar.current.component(.hour, from: now)
    nowComponents.minute = Calendar.current.component(.minute, from: now)
    nowComponents.second = Calendar.current.component(.second, from: now)
    nowComponents.timeZone = NSTimeZone.local
    now = calendar.date(from: nowComponents)!
    return now as Date
}

//
//  ShiftTableViewController.swift
//  ClockIn
//
//  Created by Luke Jansen on 28/02/2020.
//  Copyright © 2020 Luke Jansen. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreData

class ShiftTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var container: NSPersistentContainer!
    var dataManager: CoreDataManager!
    
    @IBOutlet weak var weekFilterLabel: UILabel!
    var spinnerView : SpinnerViewController!
    var picker = UIPickerView()
    var dummy = UITextField()
    
    var shiftList = [Shift]()
    var shiftWeekList = [Shift]()
    
    var selectedWeek: Date = Utility.GetWeekFromDate(date: NSDate.now)
    var weekList: [Date]!
    
    override func viewDidLoad() {
        dataManager = CoreDataManager.shared
        container = dataManager.container
        
        createSpinnerView()
        
        loadSavedData()
        
        setWeek(week: Utility.GetWeekFromDate(date: Date()))
        weekFilterLabel.isUserInteractionEnabled = true;
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OpenPicker(tapGestureRecogniser:)))
        weekFilterLabel.addGestureRecognizer(tapGesture)
        
        SetupPicker()
        
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.tableView.reloadData()
    }
    
    @IBAction func Refresh(_ sender: UIRefreshControl) {
        createSpinnerView()
        
        DispatchQueue(label: "fetchData", qos: .utility).async{
            _ = self.dataManager.fetchData()
            DispatchQueue.main.async {
                self.loadSavedData()
            }
        }
        
        if (!weekList.contains(selectedWeek)){
            setWeek(week: Utility.GetWeekFromDate(date: Date()))
        } else{
            setWeek(week: Utility.GetWeekFromDate(date: selectedWeek))
        }
        sender.endRefreshing()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        weekFilterLabel.text = "W/C " + Utility.DateToString(date: selectedWeek, dateStyle: .short, timeStyle: .none)
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shiftWeekList.count > 0{
            self.tableView.backgroundView = nil
            return shiftWeekList.count
        }
        else{
            let emptyLabel = UILabel(frame: CGRect(x: 0,y: 0,width: self.view.bounds.size.width,height: self.view.bounds.size.height))
            
            emptyLabel.text = "No shifts for this week! \nPlease choose another week above!"
            emptyLabel.textAlignment = NSTextAlignment.center
            emptyLabel.contentMode = .scaleToFill
            emptyLabel.numberOfLines = 0
            
            
            self.tableView.backgroundView = emptyLabel
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            return 0
        }        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ShiftCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ShiftTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ShiftTableViewCell.")
        }
        
        let shift = shiftWeekList[indexPath.row]
        
        cell.setupCell(shift: shift)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0;//Choose your custom row height
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if (segue.identifier == "ShiftDetail"){
            guard let shiftDetailViewController = segue.destination as? ShiftDetailTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
             
            guard let selectedShiftCell = sender as? ShiftTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
             
            let selectedShift = selectedShiftCell.cellShift!
            shiftDetailViewController.shift = selectedShift
        }
    }
    
    // MARK: - Week Code
    
    func setWeek(week: Date){
        selectedWeek = week
        getShiftsForWeek()
        tableView.reloadData()
    }
    
    func getShiftsForWeek(){
        weekList = Utility.GetWeeksFromList(list: shiftList)
        shiftWeekList = shiftList.filter {$0.week == selectedWeek}
    }
    
    //MARK: - Spinner Code
    
    func createSpinnerView() {
        spinnerView = SpinnerViewController()

        // add the spinner view controller
        addChild(spinnerView)
        spinnerView.view.frame = view.frame
        view.addSubview(spinnerView.view)
        spinnerView.didMove(toParent: self)
    }
    
    func stopSpinnerView(){
        spinnerView.willMove(toParent: nil)
        spinnerView.view.removeFromSuperview()
        spinnerView.removeFromParent()
    }
    
    //MARK: - CoreData Code
    
    func loadSavedData(){
        
        let request = Shift.createFetchRequest()
        let sort = NSSortDescriptor(key:"startDate", ascending:true)
        request.sortDescriptors = [sort]
        
        do{
            shiftList = try container.viewContext.fetch(request)
            weekList = Utility.GetWeeksFromList(list: shiftList)
            print("Fetched \(shiftList.count) shifts from file!")
        } catch {
            print("Fetch Failed!")
        }
        
        tableView.reloadData()
        stopSpinnerView()
    }
    
    //MARK: - Picker Code
    
    func SetupPicker(){
        picker.dataSource = self
        picker.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.DonePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.CancelPicker))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        dummy = UITextField(frame: CGRect.zero)
        view.addSubview(dummy)
        
        dummy.inputView = picker
        dummy.inputAccessoryView = toolBar
    }
    
    @objc func OpenPicker(tapGestureRecogniser: UITapGestureRecognizer){
        let index = weekList.firstIndex(of: selectedWeek)
        if(index != nil) {picker.selectRow(index!, inComponent: 0, animated: true)}
        
        weekFilterLabel.backgroundColor = UIColor.systemGray2
        
        dummy.becomeFirstResponder()
    }
    
    @objc func DonePicker(){
        let week = picker.selectedRow(inComponent: 0)
        setWeek(week: weekList[week])
        
        weekFilterLabel.backgroundColor = UIColor.systemGray4
        dummy.resignFirstResponder()
    }
    
    @objc func CancelPicker(){
        weekFilterLabel.backgroundColor = UIColor.systemGray4
        dummy.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weekList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "W/C " + Utility.DateToString(date: weekList[row], dateStyle: .short, timeStyle: .none)
    }
}

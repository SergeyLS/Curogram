//
//  ViewController.swift
//  Curogram
//
//  Created by Sergey Leskov on 4/6/18.
//  Copyright © 2018 Sergey Leskov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.dataSource = self
            self.tableView.delegate = self
        }
    }
    
    @IBOutlet weak var progressUI: UIProgressView!
    
    lazy var fetchResultController: NSFetchedResultsController<Number> = {
        let fetchRequest: NSFetchRequest<Number> = Number.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
    }()
    
    fileprivate let cellName = "Cell"
    
    fileprivate var timer = Timer()
    fileprivate let timerInterval = 0.1
    fileprivate let totalSeconds = 2.0
    fileprivate var currentPoseIndex = 0.0
    
    fileprivate var undo:[Int64] = []
    fileprivate var queue = OperationQueue()
    
    
    //==================================================
    // MARK: - General
    //==================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.progressUI.progress = 0
        
        self.fetchResultController.delegate = self
        do {
            try self.fetchResultController.performFetch()
        } catch {
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //==================================================
    // MARK: - func
    //==================================================
    func addNumber()  {
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            let id = arc4random_uniform(100)
            let moc = CoreDataManager.shared.newBackgroundContext()
            _ = Number(id: Int64(id), moc : moc)
            CoreDataManager.shared.save(context: moc)
        }
    }
    
    func deleteNumber(number: Number)  {
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
            let moc = CoreDataManager.shared.newBackgroundContext()
            if let uid = number.uid,
                let number = NumberManager.getByUid(uid: uid, moc: moc) {
                self?.undo.append(number.id)
                moc.delete(number)
                CoreDataManager.shared.save(context: moc)
                
            }
        }
    }
    
    func undoNumber()  {
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { [weak self] _ in
            guard let strongSelf = self else { return }
            let endIndex = strongSelf.undo.endIndex - 1
            if endIndex < 0 { return }
            
            let id = strongSelf.undo[endIndex]
            self?.undo.remove(at: endIndex)
            let moc = CoreDataManager.shared.newBackgroundContext()
            _ = Number(id: id, moc : moc)
            CoreDataManager.shared.save(context: moc)
        }
    }
    
    
    func deleteNumber()  {
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            let id = arc4random_uniform(100)
            let moc = CoreDataManager.shared.newBackgroundContext()
            _ = Number(id: Int64(id), moc : moc)
            CoreDataManager.shared.save(context: moc)
        }
    }
    
    
    func startTimer()  {
        self.timer.invalidate()
        self.currentPoseIndex = 0
        self.timer = Timer.scheduledTimer(timeInterval: self.timerInterval, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        
    }
    
    
    @objc func timerRunning() {
        self.currentPoseIndex += self.timerInterval
        progressUI.progress = Float(self.currentPoseIndex) / Float(self.totalSeconds)
        
        if  self.currentPoseIndex >= self.totalSeconds {
            self.timer.invalidate()
        }
    }
    
    
    //==================================================
    // MARK: - Action
    //==================================================
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        self.startTimer()
        self.addNumber()
    }
    
    @IBAction func undoAction(_ sender: UIBarButtonItem) {
        self.startTimer()
        self.undoNumber()
    }
    
    
}



//==================================================
// MARK: - UITableViewDataSource, UITableViewDelegate
//==================================================
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (self.fetchResultController.sections != nil) ? self.fetchResultController.sections!.count : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var resultNumber: Int = 0
        if let sections = self.fetchResultController.sections,
            sections.count > section {
            let sectionInfo = sections[section]
            resultNumber = sectionInfo.numberOfObjects
        }
        return resultNumber
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let number  = self.fetchResultController.object(at: indexPath)
        
        cell.textLabel?.text = String(number.id)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            self.startTimer()
            let number  = self.fetchResultController.object(at: indexPath)
            self.deleteNumber(number: number)
        }
    }
    
}


//==================================================
// MARK: - NSFetchedResultsControllerDelegate
//==================================================
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //        print("[BaseFetchTableVC] controllerWillChangeContent:")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        //print("[BaseFetchTableVC] controller:didChange:atSectionIndex[\(String(describing: sectionIndex))]:for[\(String(describing: type))]")
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            //            print("[BaseFetchTableVC] controller:didChange:at[\(String(describing: indexPath))]:for[insert]:newIndexPath[\(String(describing: newIndexPath))]:")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            //            print("[BaseFetchTableVC] controller:didChange:at[\(String(describing: indexPath))]:for[delete]:newIndexPath[\(String(describing: newIndexPath))]:")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            //            print("[BaseFetchTableVC] controller:didChange:at[\(String(describing: indexPath))]:for[update]:newIndexPath[\(String(describing: newIndexPath))]:")
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            //            print("[BaseFetchTableVC] controller:didChange:at[\(String(describing: indexPath))]:for[move]:newIndexPath[\(String(describing: newIndexPath))]:")
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //        print("[BaseFetchTableVC] controllerDidChangeContent:")
        //  tableView.reloadData()
        tableView.endUpdates()
    }
}


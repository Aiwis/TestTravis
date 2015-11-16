//
//  PeopleListDataProviderTests.swift
//  Birthdays
//
//  Created by Mathilde on 10/11/15.
//  Copyright © 2015 Dominik Hauser. All rights reserved.
//

import XCTest
import Birthdays
import CoreData

class PeopleListDataProviderTests: XCTestCase {
	
	var storeCoordinator: NSPersistentStoreCoordinator!
	var managedObjectContext: NSManagedObjectContext!
	var managedObjectModel: NSManagedObjectModel!
	var store: NSPersistentStore!
 
	var dataProvider: PeopleListDataProvider!
	var tableView: UITableView!
	var testRecord: PersonInfo!
	
	override func setUp() {
		super.setUp()

		// 1
		managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
		storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		store = try! storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
			configuration: nil, URL: nil, options: nil)
		
		managedObjectContext = NSManagedObjectContext()
		managedObjectContext.persistentStoreCoordinator = storeCoordinator
		
		// 2
		dataProvider = PeopleListDataProvider()
		dataProvider.managedObjectContext = managedObjectContext
		
		let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PeopleListViewController") as! PeopleListViewController
		viewController.dataProvider = dataProvider
		
		tableView = viewController.tableView
		
		testRecord = PersonInfo(firstName: "TestFirstName", lastName: "TestLastName", birthday: NSDate())
	}
	
	override func tearDown() {
		managedObjectContext = nil
		
		try! storeCoordinator.removePersistentStore(store)
		
		super.tearDown()
	}
	
	func testThatStoreIsSetUp() {
		XCTAssertNotNil(store, "no persistent store")
	}
	
	func testOnePersonInThePersistantStoreResultsInOneRow() {
		dataProvider.addPerson(testRecord)
		
		XCTAssertEqual(tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 0), 1,
		"After adding one person number of rows is not 1")
	}
}

//
//  PeopleListViewControllerTests.swift
//  Birthdays
//
//  Created by Mathilde on 10/11/15.
//  Copyright © 2015 Dominik Hauser. All rights reserved.
//

import XCTest
import Birthdays
import CoreData
import AddressBookUI

class PeopleListViewControllerTests: XCTestCase {
	
	var viewController: PeopleListViewController!
	
	override func setUp() {
		super.setUp()
		
		viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PeopleListViewController") as! PeopleListViewController
	}
	
	class MockDataProvider: NSObject, PeopleListDataProviderProtocol {
		
		var managedObjectContext: NSManagedObjectContext?
		weak var tableView: UITableView!
		var addPersonGotCalled = false
		
		func addPerson(personInfo: PersonInfo) {
			addPersonGotCalled = true
		}
		
		func fetch() { }
		
		func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
		
		func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
			return UITableViewCell()
		}
	}
	
	class MockUserDefaults: NSUserDefaults {
		
		var sortWasChanged = false
		
		override func setInteger(value: Int, forKey defaultName: String) {
			if defaultName == "sort" {
				sortWasChanged = true
			}
		}
	}
	
	class MockAPICommunicator: APICommunicatorProtocol {
		var allPersonInfo = [PersonInfo]()
		var postPersonGotCalled = false
		
		func getPeople() -> (NSError?, [PersonInfo]?) {
			return (nil, allPersonInfo)
		}
		
		func postPerson(personInfo: PersonInfo) -> NSError? {
			postPersonGotCalled = true
			return nil
		}
	}
	
	func testDataProviderHasTableViewPropertySetAfterLoading() {
		// given
		// 1
		let mockDataProvider = MockDataProvider()
		
		viewController.dataProvider = mockDataProvider
		
		// when
		// 2
		XCTAssertNil(mockDataProvider.tableView, "Before loading the table view should be nil")
		
		// 3
		let _ = viewController.view
		
		// then
		// 4
		XCTAssertTrue(mockDataProvider.tableView != nil, "The table view should be set")
		XCTAssert(mockDataProvider.tableView === viewController.tableView,
			"The table view should be set to the table view of the data source")
	}
	
	func testAddPersonIsCalledWhenSelectingAContact() {
		// given
		// 1
		let mockDataProvider = MockDataProvider()
		
		viewController.dataProvider = mockDataProvider
		
		XCTAssertFalse(mockDataProvider.addPersonGotCalled, "Before clicking on a contact cell, addPerson should not be called")
		
		// when
		// 2
		let record: ABRecord = ABPersonCreate().takeRetainedValue()
		ABRecordSetValue(record, kABPersonFirstNameProperty, "TestFirstname", nil)
		ABRecordSetValue(record, kABPersonLastNameProperty, "TestLastname", nil)
		ABRecordSetValue(record, kABPersonBirthdayProperty, NSDate(), nil)
		
		viewController.peoplePickerNavigationController(ABPeoplePickerNavigationController(),
			didSelectPerson: record)
		
		// then
		// 4
		XCTAssert(mockDataProvider.addPersonGotCalled, "addPerson should have been called")
	}
	
	func testSortWasChanged() {
		// given
		// 1
		let mockUserDefaults = MockUserDefaults(suiteName: "testing")!
		viewController.userDefaults = mockUserDefaults
		
		XCTAssertFalse(mockUserDefaults.sortWasChanged, "Sort should not be changed yet")
		
		// when
		// 2
		let segmentedControl = UISegmentedControl()
		segmentedControl.selectedSegmentIndex = 0
		segmentedControl.addTarget(viewController, action: "changeSorting:", forControlEvents: .ValueChanged)
		segmentedControl.sendActionsForControlEvents(.ValueChanged)
		
		// then
		// 4
		XCTAssert(mockUserDefaults.sortWasChanged, "Sort should have been changed")
	}
	
	func testFetchingPeopleFromAPICallsAddPeople() {
		// given
		// 1
		let mockDataProvider = MockDataProvider()
		viewController.dataProvider = mockDataProvider
		
		// 2
		let mockCommunicator = MockAPICommunicator()
		mockCommunicator.allPersonInfo = [PersonInfo(firstName: "firstname", lastName: "lastname",
			birthday: NSDate())]
		viewController.communicator = mockCommunicator
		
		// when
		viewController.fetchPeopleFromAPI()
		
		// then
		// 3
		XCTAssert(mockDataProvider.addPersonGotCalled, "addPerson should have been called")
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
}

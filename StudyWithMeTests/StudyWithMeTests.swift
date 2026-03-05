//
//  StudyWithMeTests.swift
//  StudyWithMeTests
//
//  Created by Noel Erulu on 2/23/26.
//

import XCTest
@testable import StudyWithMe

@MainActor
final class StudyWithMeTests: XCTestCase {

    private var sut: UserStudySessionViewModel!

    override func setUp() {
        super.setUp()
        sut = UserStudySessionViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialUserStudySessionsIsEmpty() {
        XCTAssertTrue(sut.userStudySessions.isEmpty)
    }

    func testInitialOtherUserStudySessionsIsEmpty() {
        XCTAssertTrue(sut.otherUserStudySessions.isEmpty)
    }

    func testInitialLoadingStateIsFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    func testInitialErrorMessageIsNil() {
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - Type Safety Tests

    func testUserStudySessionsIsCorrectType() {
        XCTAssertTrue(type(of: sut.userStudySessions) == [UserStudySession].self)
    }

    func testOtherUserStudySessionsIsCorrectType() {
        XCTAssertTrue(type(of: sut.otherUserStudySessions) == [UserStudySession].self)
    }

    // MARK: - Async Fetch Tests

    func testReadUserSessionsStopsLoading() async {
        await sut.readUserSessions()
        XCTAssertFalse(sut.isLoading)
    }

    func testReadOtherUserSessionsStopsLoading() async {
        await sut.readOtherUserSessions()
        XCTAssertFalse(sut.isLoading)
    }

    func testUserSessionsArrayExistsAfterFetch() async {
        await sut.readUserSessions()
        XCTAssertNotNil(sut.userStudySessions)
    }

    func testOtherUserSessionsArrayExistsAfterFetch() async {
        await sut.readOtherUserSessions()
        XCTAssertNotNil(sut.otherUserStudySessions)
    }
}

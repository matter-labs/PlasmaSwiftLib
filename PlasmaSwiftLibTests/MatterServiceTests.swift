//
//  MatterServiceTests.swift
//  PlasmaSwiftLibTests
//
//  Created by Anton Grigorev on 21.10.2018.
//  Copyright © 2018 The Matter. All rights reserved.
//

import XCTest
import BigInt
import secp256k1_swift
import EthereumAddress

@testable import PlasmaSwiftLib

class MatterServiceTests: XCTestCase {
    
    let testHelpers = TestHelpers()

    func testGetListUTXO() {
        let completedGetListExpectation = expectation(description: "Completed")
        MatterService().getListUTXOs(for: EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4")!, onTestnet: true) { (result) in
            switch result {
            case .Success(let r):
                DispatchQueue.main.async {
                    for utxo in r {
                        print(utxo.value)
                    }
                    completedGetListExpectation.fulfill()
                }
            case .Error(let error):
                DispatchQueue.main.async {
                    XCTAssertNil(error)
                    completedGetListExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 30, handler: nil)
    }

    func testSendTransaction() {
        let completedSendExpectation = expectation(description: "Completed")
        let privKey = Data(hex: "BDBA6C3D375A8454993C247E2A11D3E81C9A2CE9911FF05AC7FF0FCCBAC554B5")
        guard let address = EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4") else {
            XCTFail("Wrong address")
            completedSendExpectation.fulfill()
            return
        }
        MatterService().getListUTXOs(for: address, onTestnet: true) { (result) in
            switch result {
            case .Success(let r):
                guard r.count == 1 else {
                    print("The inputs count \(r.count) is wrong")
                    completedSendExpectation.fulfill()
                    return
                }
                guard let transaction = self.testHelpers.UTXOsToTransaction(utxos: r, address: address, txType: .split) else {
                    XCTFail("Can't create transaction")
                    completedSendExpectation.fulfill()
                    return
                }
                guard let signedTransaction = transaction.sign(privateKey: privKey) else {
                    XCTFail("Can't sign transaction")
                    completedSendExpectation.fulfill()
                    return
                }
                XCTAssertEqual(address, signedTransaction.sender)
                MatterService().sendRawTX(transaction: signedTransaction, onTestnet: true) { (result) in
                    switch result {
                    case .Success(let r):
                        DispatchQueue.main.async {
                            XCTAssert(r == true)
                            completedSendExpectation.fulfill()
                        }
                    case .Error(let error):
                        DispatchQueue.main.async {
                            XCTAssertNil(error)
                            completedSendExpectation.fulfill()
                        }
                    }
                }
            case .Error(let error):
                DispatchQueue.main.async {
                    XCTAssertNil(error)
                    completedSendExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 30, handler: nil)
    }

    func testMergeUTXOs() {
        let completedSendExpectation = expectation(description: "Completed")
        let privKey = Data(hex: "BDBA6C3D375A8454993C247E2A11D3E81C9A2CE9911FF05AC7FF0FCCBAC554B5")
        guard let address = EthereumAddress("0x832a630b949575b87c0e3c00f624f773d9b160f4") else {
            XCTFail("Wrong address")
            completedSendExpectation.fulfill()
            return
        }
        MatterService().getListUTXOs(for: address, onTestnet: true) { (result) in
            switch result {
            case .Success(let r):
                guard r.count == 2 else {
                    print("The inputs count \(r.count) is wrong")
                    completedSendExpectation.fulfill()
                    return
                }
                guard let transaction = self.testHelpers.UTXOsToTransaction(utxos: r, address: address, txType: .merge) else {
                    XCTFail("Can't create transaction")
                    completedSendExpectation.fulfill()
                    return
                }
                guard let signedTransaction = transaction.sign(privateKey: privKey) else {
                    XCTFail("Can't sign transaction")
                    completedSendExpectation.fulfill()
                    return
                }
                XCTAssertEqual(address, signedTransaction.sender)
                MatterService().sendRawTX(transaction: signedTransaction, onTestnet: true) { (result) in
                    switch result {
                    case .Success(let r):
                        DispatchQueue.main.async {
                            XCTAssert(r == true)
                            completedSendExpectation.fulfill()
                        }
                    case .Error(let error):
                        DispatchQueue.main.async {
                            XCTAssertNil(error)
                            completedSendExpectation.fulfill()
                        }
                    }
                }
            case .Error(let error):
                DispatchQueue.main.async {
                    XCTAssertNil(error)
                    completedSendExpectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 30, handler: nil)
    }
}
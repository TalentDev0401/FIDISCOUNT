//
//  TypeAlies.swift
//  Fid
//
//  Created by CROCODILE on 11.03.2021.
//

import Foundation

public typealias EmptyCompletion = () -> Void
public typealias CompletionObject<T> = (_ response: T) -> Void
public typealias CompletionOptionalObject<T> = (_ response: T?) -> Void
public typealias CompletionResponse = (_ response: Result<Void, Error>) -> Void

public enum FirestoreResponse {
  case success
  case failure
}



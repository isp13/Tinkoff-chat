//
//  RootAssembly.swift
//  TinkoffChat
//
//  Created by Никита Казанцев on 11.04.2021.
//

import Foundation

class RootAssembly {
  lazy var presentationAssembly: PresenentationAssemblyProtocol = PresenentationAssembly(serviceAssembly: self.serviceAssembly)
  private lazy var serviceAssembly: ServiceAssemblyProtocol = ServiceAssembly(coreAssembly: self.coreAssembly)
  private lazy var coreAssembly: CoreAssemblyProtocol = CoreAssembly()
}

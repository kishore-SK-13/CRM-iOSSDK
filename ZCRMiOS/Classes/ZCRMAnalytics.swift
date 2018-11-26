//
//  ZCRMAnalytics.swift
//  ZCRMiOS
//
//  Created by Kalyani shiva on 02/09/18.
//
import Foundation
open class ZCRMAnalytics
{
    // SINGLETON OBJECT : There's no need for more than one instance of ZCRMAnalytics to exist
    // It's not actually a class and is just used for grouping methods under a name
    // No stored Properties and methods to manipulate properties
    init(){}
    public static let shared = ZCRMAnalytics()
    
    public func getAllDashboards(then onCompletion:@escaping ArrayOfDashboards)
    {
        // 200 is the maxNumber of records that can be retreived in an API Call
        DashboardAPIHandler().getAllDashboards(fromPage: 1, withPerPageOf: 200) { (resultType) in
            onCompletion(resultType)
        }
    }
    
    public func getAllDashboards(fromPage page:Int, perPage:Int, then onCompletion: @escaping ArrayOfDashboards)
    {
        DashboardAPIHandler().getAllDashboards(fromPage: page,withPerPageOf: perPage) { (resultType) in
            onCompletion(resultType)
        }
    }
    
    public func getDashboardWithId(id: Int64,then onCompletion: @escaping Dashboard)
    {
        DashboardAPIHandler().getDashboardWithId(id: id) { (resultType) in
            onCompletion(resultType)
        }
    }
    
    public func getDashboardComponentColorThemes( onCompletion: @escaping ArrayOfColorThemes )
    {
        DashboardAPIHandler().getDashboardComponentColorThemes { (resultType) in
            onCompletion(resultType)
        }
    }
}
// (TypeAliases) Used by Model and Handler Classes
extension ZCRMAnalytics
{
    public typealias Dashboard = (Result.DataResponse<ZCRMDashboard,APIResponse>) -> Void
    public typealias ArrayOfDashboards = (Result.DataResponse<[ZCRMDashboard],BulkAPIResponse>) -> Void
    public typealias ArrayOfColorThemes = (Result.DataResponse<[ZCRMDashboardComponentColorThemes],APIResponse>) -> Void
    public typealias RefreshResponse = (Result.Response<APIResponse>) -> Void
    public typealias DashboardComponent = (Result.DataResponse<ZCRMDashboardComponent,APIResponse>) -> Void
    
}
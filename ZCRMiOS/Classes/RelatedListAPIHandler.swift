//
//  RelatedListAPIHandler.swift
//  ZCRMiOS
//
//  Created by Vijayakrishna on 18/11/16.
//  Copyright © 2016 zohocrm. All rights reserved.
//

internal class RelatedListAPIHandler
{
	private var parentRecord : ZCRMRecord
	private var relatedList : ZCRMModuleRelation
    private var junctionRecord : ZCRMJunctionRecord?
    
    private init( parentRecord : ZCRMRecord, relatedList : ZCRMModuleRelation, junctionRecord : ZCRMJunctionRecord? )
    {
        self.parentRecord = parentRecord
        self.relatedList = relatedList
        self.junctionRecord = junctionRecord
    }
	
	convenience init(parentRecord : ZCRMRecord, relatedList : ZCRMModuleRelation)
    {
        self.init(parentRecord: parentRecord, relatedList: relatedList, junctionRecord: nil)
	}
	
    convenience init( parentRecord : ZCRMRecord, junctionRecord : ZCRMJunctionRecord )
    {
        self.init(parentRecord: parentRecord, relatedList: ZCRMModuleRelation(parentRecord: parentRecord, junctionRecord: junctionRecord), junctionRecord: junctionRecord)
    }
    
    internal func getRecords(page : Int, per_page : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String? ) throws -> BulkAPIResponse
	{
		var records : [ZCRMRecord] = [ZCRMRecord]()
        let request : APIRequest = APIRequest(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())", reqMethod: RequestMethod.GET)
		request.addParam(paramName: "page", paramVal: String(page))
		request.addParam(paramName: "per_page", paramVal: String(per_page))
        if(sortByField != nil)
        {
            request.addParam(paramName: "sort_by", paramVal: sortByField!)
            request.addParam(paramName: "sort_order", paramVal: sortOrder!.rawValue)
        }
        if ( modifiedSince != nil )
        {
            request.addHeader( headerName : "If-Modified-Since", headerVal : modifiedSince! )
        }
        print( "Request : \( request.toString() )" )
		
        let response = try request.getBulkAPIResponse()

        let responseJSON = response.getResponseJSON()
        if responseJSON.isEmpty == false
        {
            let recordsList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : "data" )
            for recordDetails in recordsList
            {
                let record : ZCRMRecord = ZCRMRecord(moduleAPIName: self.parentRecord.getModuleAPIName(), recordId: recordDetails.optInt64(key: "id")!)
                EntityAPIHandler(record: record).setRecordProperties(recordDetails: recordDetails)
                records.append(record)
            }
            response.setData(data: records)
        }
        return response
	}
	
	internal func getNotes(page : Int, per_page : Int, sortByField : String?, sortOrder : SortOrder?, modifiedSince : String?) throws -> BulkAPIResponse
	{
		var notes : [ZCRMNote] = [ZCRMNote]()
        let request : APIRequest = APIRequest(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())", reqMethod: RequestMethod.GET)
		request.addParam(paramName: "page", paramVal: String(page))
		request.addParam(paramName: "per_page", paramVal: String(per_page))
        if(sortByField != nil)
        {
            request.addParam(paramName: "sort_by", paramVal: sortByField!)
            request.addParam(paramName: "sort_order", paramVal: sortOrder!.rawValue)
        }
        if ( modifiedSince != nil )
        {
            request.addHeader( headerName : "If-Modified-Since", headerVal : modifiedSince! )
        }
        print( "Request : \( request.toString() )" )
		
        let response = try request.getBulkAPIResponse()
		
        let responseJSON = response.getResponseJSON()
        if responseJSON.isEmpty == false
        {
            let notesList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : "data" )
            for noteDetails in notesList
            {
                notes.append( self.getZCRMNote( noteDetails : noteDetails, note : ZCRMNote( noteId : noteDetails.getInt64( key : "id" ) ) ) )
            }
            response.setData(data: notes)
        }
        return response
	}
	
	internal func getAllAttachmentsDetails(page : Int, per_page : Int, modifiedSince : String?) throws -> BulkAPIResponse
	{
		var attachments : [ZCRMAttachment] = [ZCRMAttachment]()
        let request : APIRequest = APIRequest(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())", reqMethod: RequestMethod.GET)
		request.addParam(paramName: "page", paramVal: String(page))
		request.addParam(paramName: "per_page", paramVal: String(per_page))
        if ( modifiedSince != nil )
        {
            request.addHeader( headerName : "If-Modified-Since", headerVal : modifiedSince! )
        }
        print( "Request : \( request.toString() )" )
		
        let response = try request.getBulkAPIResponse()
		
        let responseJSON = response.getResponseJSON()
        if responseJSON.isEmpty == false
        {
            let attachmentsList:[[String:Any]] = responseJSON.getArrayOfDictionaries( key : "data" )
            for attachmentDetails in attachmentsList
            {
                attachments.append(self.getZCRMAttachment(attachmentDetails: attachmentDetails))
            }
            response.setData(data: attachments)
        }
        return response
	}
	
    internal func uploadAttachment( filePath : String ) throws -> APIResponse
    {
        let request : APIRequest = APIRequest( urlPath : "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())", reqMethod : RequestMethod.POST )
        print( "Request : \( request.toString() )" )
        let response = try request.uploadFile( filePath : filePath )
        
        let responseJSON = response.getResponseJSON()
        let respDataArr : [[String:Any?]] = responseJSON.getArrayOfDictionaries(key: "data")
        let respData : [String:Any?] = respDataArr[0]
        let recordDetails : [String:Any] = respData.getDictionary( key : "details" )
        response.setData(data: self.getZCRMAttachment(attachmentDetails: recordDetails))
        return response
    }
    
    internal func uploadLinkAsAttachment( attachmentURL : String ) throws -> APIResponse
    {
        let request : APIRequest = APIRequest( urlPath : "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())", reqMethod : RequestMethod.POST )
        request.addParam( paramName : "attachmentUrl", paramVal : attachmentURL )
        print( "Request : \( request.toString() )" )
        let response = try request.uploadLink()
        let responseJSONArray : [ [ String : Any ] ]  = response.getResponseJSON().getArrayOfDictionaries( key : "data" )
        let details = responseJSONArray[ 0 ].getDictionary( key : "details" )
        response.setData( data : self.getZCRMAttachment(attachmentDetails: details))
        return response
    }
    
	internal func downloadAttachment(attachmentId: Int64) throws -> FileAPIResponse
	{
		let request : APIRequest = APIRequest(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\(attachmentId)", reqMethod: RequestMethod.GET)
        print( "Request : \( request.toString() )" )
		return try request.downloadFile()
	}
    
    internal func deleteAttachment( attachmentId : Int64 ) throws -> APIResponse
    {
        let request = APIRequest( urlPath : "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\(attachmentId)", reqMethod: RequestMethod.DELETE )
        print( "Request : \( request.toString() )" )
        let response = try request.getAPIResponse()
        return response
    }
	
	internal func addNote(note : ZCRMNote) throws -> APIResponse
	{
		let request : APIRequest = APIRequest(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String( self.parentRecord.getId()))/\(self.relatedList.getAPIName())", reqMethod: RequestMethod.POST)
		var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
		var dataArray : [[String:Any]] = [[String:Any]]()
		dataArray.append(self.getZCRMNoteAsJSON(note: note))
		reqBodyObj["data"] = dataArray
		request.setRequestBody(body: reqBodyObj)
        print( "Request : \( request.toString() )" )
		
		let response = try request.getAPIResponse()
		
        let responseJSON = response.getResponseJSON()
		let respDataArr : [[String:Any?]] = responseJSON.optArrayOfDictionaries(key: "data")!
		let respData : [String:Any?] = respDataArr[0]
		let recordDetails : [String:Any] = respData.getDictionary( key : "details" )
        response.setData(data: self.getZCRMNote(noteDetails: recordDetails, note: note))
        return response
	}
	
	internal func updateNote(note: ZCRMNote) throws -> APIResponse
	{
        if note.getId() == nil
        {
            throw ZCRMSDKError.ProcessingError("Note ID MUST NOT be nil")
        }
        let noteId : String = String( note.getId()! )
        let request : APIRequest = APIRequest(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\(noteId)", reqMethod: RequestMethod.PUT)
		var reqBodyObj : [String:[[String:Any]]] = [String:[[String:Any]]]()
		var dataArray : [[String:Any]] = [[String:Any]]()
		dataArray.append(self.getZCRMNoteAsJSON(note: note))
		reqBodyObj["data"] = dataArray
		request.setRequestBody(body: reqBodyObj)
        print( "Request : \( request.toString() )" )
		
		let response = try request.getAPIResponse()
        
        let responseJSON = response.getResponseJSON()
        let respDataArr : [[String:Any?]] = responseJSON.optArrayOfDictionaries(key: "data")!
        let respData : [String:Any?] = respDataArr[0]
        let recordDetails : [String:Any] = respData.getDictionary(key: "details")
        response.setData(data: self.getZCRMNote(noteDetails: recordDetails, note: note))
        return response
	}
	
	internal func deleteNote(note: ZCRMNote) throws -> APIResponse
	{
        if note.getId() == nil
        {
            throw ZCRMSDKError.ProcessingError("Note ID MUST NOT be nil")
        }
        let noteId : String = String( note.getId()! )
		let request : APIRequest = APIRequest(urlPath: "/\(self.parentRecord.getModuleAPIName())/\(String(self.parentRecord.getId()))/\(self.relatedList.getAPIName())/\( noteId )", reqMethod: RequestMethod.DELETE)
        print( "Request : \( request.toString() )" )
		return try request.getAPIResponse()
	}
	
	internal func getZCRMAttachment(attachmentDetails : [String:Any?]) -> ZCRMAttachment
	{
        var createdBy : ZCRMUser?
		let attachment : ZCRMAttachment = ZCRMAttachment(parentRecord: self.parentRecord, attachmentId: attachmentDetails.getInt64(key: "id"))
        if ( attachmentDetails.hasValue( forKey : "File_Name" ) )
        {
            let fileName : String = attachmentDetails.optString( key : "File_Name" )!
            attachment.setFileName( fileName : fileName )
            let fileType = fileName.pathExtension()
            attachment.setFileType(type: fileType)
        }
        if(attachmentDetails.hasValue(forKey: "Size"))
        {
            attachment.setFileSize(size: Int64(attachmentDetails.optInt64(key: "Size")!))
        }
        if ( attachmentDetails.hasValue( forKey : "Created_By" ) )
        {
            let createdByDetails : [String:Any] = attachmentDetails.getDictionary(key: "Created_By")
            createdBy = ZCRMUser(userId: createdByDetails.getInt64(key: "id"), userFullName: createdByDetails.getString(key: "name"))
            attachment.setCreatedByUser(createdByUser: createdBy)
            attachment.setCreatedTime(createdTime: attachmentDetails.getString(key: "Created_Time"))
        }
        if(attachmentDetails.hasValue(forKey: "Modified_By"))
        {
            let modifiedByDetails : [String:Any] = attachmentDetails.getDictionary(key: "Modified_By")
            let modifiedBy : ZCRMUser = ZCRMUser(userId: modifiedByDetails.getInt64(key: "id"), userFullName: modifiedByDetails.getString(key: "name"))
            attachment.setModifiedByUser(modifiedByUser: modifiedBy)
            attachment.setModifiedTime(modifiedTime: attachmentDetails.getString(key: "Modified_Time"))
        }
		if(attachmentDetails.hasValue(forKey: "Owner"))
		{
			let ownerDetails : [String:Any] = attachmentDetails.getDictionary(key: "Owner")
			let owner : ZCRMUser = ZCRMUser(userId: ownerDetails.getInt64(key: "id"), userFullName: ownerDetails.getString(key: "name"))
			attachment.setOwner(owner: owner)
		}
        else if( createdBy != nil )
        {
            attachment.setOwner( owner : createdBy! )
        }
		return attachment
	}
	
    internal func getZCRMNote(noteDetails : [String:Any?], note : ZCRMNote) -> ZCRMNote
	{
        var createdBy : ZCRMUser?
		note.setId( noteId : noteDetails.getInt64( key : "id" ) )
        if ( noteDetails.hasValue( forKey : "Note_Title" ) )
        {
            note.setTitle( title : noteDetails.getString( key : "Note_Title" ) )
        }
        if ( noteDetails.hasValue( forKey : "Note_Content" ) )
        {
            note.setContent( content : noteDetails.getString( key : "Note_Content" ) )
        }
        if ( noteDetails.hasValue( forKey : "Created_By" ) )
        {
            let createdByDetails : [String:Any] = noteDetails.getDictionary(key: "Created_By")
            createdBy = ZCRMUser(userId: createdByDetails.getInt64(key: "id"), userFullName: createdByDetails.getString(key: "name"))
            note.setCreatedByUser(createdByUser: createdBy)
            note.setCreatedTime(createdTime: noteDetails.getString(key: "Created_Time"))
        }
        if ( noteDetails.hasValue( forKey : "Modified_By" ) )
        {
            let modifiedByDetails : [String:Any] = noteDetails.getDictionary( key : "Modified_By" )
            let modifiedBy : ZCRMUser = ZCRMUser(userId: modifiedByDetails.getInt64(key: "id"), userFullName: modifiedByDetails.getString(key: "name"))
            note.setModifiedByUser(modifiedByUser: modifiedBy)
            note.setModifiedTime(modifiedTime: noteDetails.getString(key: "Modified_Time"))
        }
        if( noteDetails.hasValue( forKey: "Owner" ) )
        {
            let ownerDetails : [String:Any] = noteDetails.getDictionary(key: "Owner")
            let owner : ZCRMUser = ZCRMUser(userId: ownerDetails.getInt64(key: "id"), userFullName: ownerDetails.getString(key: "name"))
            note.setOwner(owner: owner)
        }
        else if( createdBy != nil )
        {
            note.setOwner( owner : createdBy! )
        }
        if(noteDetails.hasValue(forKey: "$attachments"))
        {
            let attachmentsList : [[String:Any?]] = noteDetails.getArrayOfDictionaries(key: "$attachments")
            for attachmentDetails in attachmentsList
            {
                note.addAttachment(attachment: self.getZCRMAttachment(attachmentDetails: attachmentDetails))
            }
        }
		return note
	}
	
	internal func getZCRMNoteAsJSON(note : ZCRMNote) -> [String:Any]
	{
		var noteJSON : [String:Any] = [String:Any]()
		noteJSON["Note_Title"] = note.getTitle()
		noteJSON["Note_Content"] = note.getContent()
		return noteJSON
	}
    
    internal func addRelation() throws -> APIResponse
    {
        let request : APIRequest = APIRequest( urlPath : "/\(self.parentRecord.getModuleAPIName())/\(self.parentRecord.getId())/\(self.junctionRecord!.getApiName())/\(self.junctionRecord!.getId())", reqMethod : RequestMethod.PUT )
        
        var reqBodyObj : [ String : [ [ String : Any ] ] ] = [ String : [ [ String : Any ] ] ]()
        var dataArray : [ [ String : Any ] ] = [ [ String : Any ] ]()
        if( self.junctionRecord!.getRelatedDetails() != nil )
        {
             dataArray.append( self.getRelationDetailsAsJSON( releatedDetails : self.junctionRecord!.getRelatedDetails()! ) as Any as! [ String : Any ] )
        }
        else
        {
            dataArray.append( [ String : Any ]() )
        }
        reqBodyObj["data"] = dataArray
        request.setRequestBody( body : reqBodyObj )
        print( "Request : \( request.toString() )" )
        return try request.getAPIResponse()
    }
    
    private func getRelationDetailsAsJSON( releatedDetails : [ String : Any ] ) -> [ String : Any? ]
    {
        var relatedDetailsJSON : [ String : Any ] = [ String : Any ]()
        for key in releatedDetails.keys
        {
            let value = releatedDetails[ key ]
            relatedDetailsJSON[ key ] = value
        }
        return relatedDetailsJSON
    }
    
    internal func deleteRelation() throws -> APIResponse
    {
        let request : APIRequest = APIRequest( urlPath : "/\(self.parentRecord.getModuleAPIName())/\( String( self.parentRecord.getId() ) )/\(self.junctionRecord!.getApiName())/\(self.junctionRecord!.getId())", reqMethod : RequestMethod.DELETE )
        print( "Request : \( request.toString() )" )
        return try request.getAPIResponse()
    }
    
}
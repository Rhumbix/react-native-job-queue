import Foundation
import SQLite3

struct Job {
    var id: NSString
    var workerName: NSString
    var active:Int32
    var payload: NSString
    var metaData: NSString
    var attempts: Int32
    var created: NSString
    var failed: NSString
    var timeout: Int32
    var priority: Int32
}
extension Job: SQLTable {
    static var createStatement: String {
        return """
        CREATE TABLE IF NOT EXISTS Job(
        id CHAR(36) PRIMARY KEY NOT NULL,
        workerName CHAR(255) NOT NULL,
        active INTEGER NOT NULL,
        payload CHAR(1024),
        metaData CHAR(1024),
        attempts INTEGER NOT NULL,
        created CHAR(255),
        failed CHAR(255),
        timeout INTEGER NOT NULL,
        priority Integer NOT NULL
        );
        """
    }
}
extension SQLiteDatabase {
    func add(job: Job) throws {
        let insertSql = "INSERT INTO Job (id, workerName, active, payload, metaData, attempts, created, failed,timeout,priority) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        guard (sqlite3_bind_text(insertStatement, 1, job.id.utf8String,-1,nil) == SQLITE_OK  &&
            sqlite3_bind_text(insertStatement, 2, job.workerName.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 3,job.active) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 4, job.payload.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 5, job.metaData.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 6,job.attempts) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 7, job.created.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(insertStatement, 8, job.failed.utf8String, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 9, job.timeout) == SQLITE_OK &&
            sqlite3_bind_int(insertStatement, 10, job.priority) == SQLITE_OK
            
            )else {
                throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        print("Successfully inserted row.")
    }
    func getJobBy(id: String) -> Job? {
        let querySql = "SELECT * FROM Job WHERE id = ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
            return nil
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            return nil
        }
        
        let id = sqlite3_column_int(queryStatement, 0)
        
        let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
        let name = String(cString: queryResultCol1!) as NSString
        
        return Job(id: id, name: name)
    }
    func getNextJob() -> Job? {
        let querySql = "SELECT * FROM job WHERE active == 0  ORDER BY priority,datetime(created) LIMIT 1;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            return nil
        }
        
        let id = sqlite3_column_int(queryStatement, 0)
        let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
        let workerName = String(cString: queryResultCol1!) as NSString
        let active=sqlite3_column_int(queryStatement, 2)
        let payload: NSString
        let metaData: NSString
        let attempts=sqlite3_column_int(queryStatement, 5)
        let created: NSString
        let failed: NSString
        let timeout=sqlite3_column_int(queryStatement, 9)
        let priority=sqlite3_column_int(queryStatement, 10)
        return Job(id: id, workerName: name)
    }
    
    func delete(job: Job) throws{
        let querySql = "DELETE * FROM Job WHERE id = ?;"
        guard let deleteStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_text(insertStatement, 1, job.id.utf8String,-1,nil) == SQLITE_OK else {
           throw SQLiteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
           throw SQLiteError.Step(message: errorMessage)
        }
        
     
    }
}

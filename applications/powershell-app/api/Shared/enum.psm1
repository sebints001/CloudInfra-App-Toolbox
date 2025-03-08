Add-Type -TypeDefinition @'
public enum LogType {
    Request = 1,
    Response = 2
}
'@

Add-Type -TypeDefinition @'
public enum HttpVerbType {
    Post = 1,
    Put = 2,
    Patch = 3,
    Delete = 4,
    Get = 5
}
'@

Add-Type -TypeDefinition @'
public enum LogLevel {
    Information = 1,
    Warning = 2,
    Error = 3
}
'@
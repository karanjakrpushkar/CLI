/********************************************************************************************************
* @Author         ext.chandrakanth.reddy@cargotec.com
* @Description    This is a Utility class for creating a Json format string
* @TestClass      <TBD>
* @CreatedDate    07-23-2018

*********************************************************************************************************/
public class CGT_JsonGeneratorUtilities{

/********************************************************************************************************
* @description      This is a inner class with is used for creating the Header in Json String
*********************************************************************************************************/
   // This class is used for generating the Header in Json string
    public class StandardHeader {
        public String userId;
        public String messageID;
        public String event;
        public String requestedDateTime;
        public String responseDateTime;
        public String statusCode;
        public String errorMsg;
        public String orgName;
        // Constructor method for invoking StandardHeader
        public StandardHeader(String userId,String messageID,String event,String requestedDateTime,
                            String responseDateTime,String statusCode,String errorMsg,String orgName){
            this.userId=userId;
            this.messageID=messageID;
            this.event=event;
            this.requestedDateTime=requestedDateTime;
            this.responseDateTime=responseDateTime;
            this.statusCode=statusCode;
            this.errorMsg=errorMsg;
            this.orgName=orgName;
        }
        // Constructor method for invoking StandardHeader
        public StandardHeader(String messageID){
            this.messageID=messageID;
        }
    }

/********************************************************************************************************
* @description      This is a inner class with is used for Parsing the Hson String and fetching the field values
*********************************************************************************************************/
    // This class is for Parsing the Json string with responseHeader tag
    public class ResponseParser{

        public StandardHeader responseHeader;
        
        public ResponseParser(StandardHeader responseHeader){
            this.responseHeader=responseHeader;
        }
    }
/********************************************************************************************************
* @description      This is a inner class with is used for fetching the field value from an object
*********************************************************************************************************/
    public class Field{
        public String name;
        public Object value;
        // this method is used for assigning the values to name and Value variables
        public Field(String name,Object value){
            this.name=name;
            this.value=value;
        }
    }
/********************************************************************************************************
* @description      This is a inner class with is used for creating the List of Field class variables
*********************************************************************************************************/
    public class ObjectName{
        public List<Field> fields;
        // It takes list<FieldClass> as parameters
        public ObjectName(List<Field> fields){
            this.fields=fields;
        }
    }
/*****************************************************************************************************************************
* @description   : This is a constructor method which will take StandardHeader and Map<String,List<ObjectName>> as parameters
******************************************************************************************************************************/
 
    public StandardHeader standardHeader;
    Map<String,ObjectName> messagebody;
    public CGT_JsonGeneratorUtilities(StandardHeader standardHeader,Map<String,List<ObjectName>> objectDetails){
        this.standardHeader=standardHeader;
        this.messagebody=messagebody;
    }

}
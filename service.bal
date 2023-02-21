import ballerinax/mysql.driver as _;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/graphql;

type ProdcutRecord record {
    string title;
    string description;
    string includes;
    string intended_for;
    string color;
    string material;
    decimal price;
};

service class Product{

    private final readonly & ProdcutRecord prodcutRecord;

    function init(ProdcutRecord prodcutRecord) {
        self.prodcutRecord = prodcutRecord.cloneReadOnly();
    }
    resource function get title() returns string {
        return self.prodcutRecord.title;
    }
    resource function get description() returns string {
        return self.prodcutRecord.description;
    }
    resource function get includes() returns string {
        return self.prodcutRecord.includes;
    }
    resource function get inteded_for() returns string {
        return self.prodcutRecord.intended_for;
    }
    resource function get color() returns string {
        return self.prodcutRecord.color;
    }
    resource function get material() returns string {
        return self.prodcutRecord.material;
    }
    resource function get price() returns decimal {
        return self.prodcutRecord.price;
    }
}

service / on new graphql:Listener(9090) {

    # A resource for generating greetings
    # + return - string name with hello message or error
    resource function get allProducts() returns Product[]|error {
        // Send a response back to the caller.
        mysql:Client dataStore = check new (host = "sahackathon.mysql.database.azure.com", user = "choreo", password = "wso2!234", database = "rushmin_db", options = {ssl: {mode: mysql:SSL_REQUIRED}});

        sql:ParameterizedQuery query = `SELECT * FROM product`;
        stream<ProdcutRecord, sql:Error?> resultStream = dataStore->query(query);

        ProdcutRecord[]|error? productRecords = from var {title, description, includes, intended_for, color, material, price} in resultStream
        select {
            title: title,
            description: description,
            includes: includes,
            intended_for: intended_for,
            color: color,
            material:material,
            price:price
        };
        
    Product[] products = [];
    if productRecords is ProdcutRecord[] {
        products = productRecords.map(pr => new Product(pr));
    }
    return products;

    }
}

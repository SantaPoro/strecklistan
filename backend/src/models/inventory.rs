use chrono::NaiveDateTime;
use juniper_codegen::GraphQLObject;
use serde_derive::{Deserialize, Serialize};

#[derive(Queryable, GraphQLObject, Serialize, Deserialize, Debug, PartialEq)]
pub struct InventoryItem {
    pub id: i32,
    pub name: String,
    pub price: Option<i32>,
}

#[derive(Queryable, GraphQLObject, Serialize, Deserialize, Debug, PartialEq)]
pub struct InventoryItemStock {
    pub id: i32,
    pub name: String,
    pub stock: i32,
}

#[derive(Queryable, GraphQLObject, Serialize, Deserialize, Debug, PartialEq)]
pub struct Transaction {
    pub id: i32,
    pub amount: i32,
    pub description: Option<String>,
    pub time: NaiveDateTime,
}

#[derive(Queryable, GraphQLObject, Serialize, Deserialize, Debug, PartialEq)]
pub struct TransactionBundle {
    pub id: i32,
    pub transaction_id: i32,
    pub bundle_price: Option<i32>,
    pub change: i32,
}

#[derive(Queryable, GraphQLObject, Serialize, Deserialize, Debug, PartialEq)]
pub struct TransactionItem {
    pub id: i32,
    pub bundle_id: i32,
    pub item_id: i32,
}

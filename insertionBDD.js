import axios from "axios";
import neo4j from "neo4j-driver";
import dotenv from "dotenv";

dotenv.config();

function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

let catégoriesEng = [];

const response = await axios.get("https://dummyjson.com/products/categories");
for (let cat of response.data) {
  catégoriesEng.push(cat);
}

const driver = neo4j.driver(
  process.env.NEO4J_URI,
  neo4j.auth.basic(process.env.NEO4J_USER, process.env.NEO4J_PASSWORD)
);
const session = driver.session();

for (let i of catégoriesEng) {
  await session.run(
    `CREATE (n:Category {
          categoryName: "${capitalizeFirstLetter(i.name)}",
          categoryDescription: "None"
        }) RETURN n`
  );
}

let Produits = [];
const res = await axios.get("https://dummyjson.com/products?limit=100");
for (let Prod of res.data.products) {
  Produits.push(Prod);
}

for (let i of Produits) {
  await session.run(
    `CREATE (p:Product {
          ProductName: "${i.title}",
          ProductDescription: "${i.description}",
          ProductPrice: "${i.price}",
          ProductStock: "${i.stock}",
          ProductBrand: "${i.brand}"
        })
        WITH p
        MATCH (c:Category {categoryName: "${capitalizeFirstLetter(
          i.category
        )}"})
        CREATE (p)-[:CategorisedBy]->(c)`
  );
}

let Utilisateurs = [];
const resp = await axios.get("https://dummyjson.com/users?limit=100");
for (let user of resp.data.users) {
  Utilisateurs.push(user);
}

for (let i of Utilisateurs) {
  await session.run(
    `CREATE (u:User {
          id: ${i.id},
          email: "${i.email}",
          password: "${i.password}",
          firstName: "${i.firstName}",
          lastName: "${i.lastName}",
          dateOfBirth: "${i.birthDate}",
          phoneNumber: "${i.phone}",
          sexe: "${i.gender}"
        })`
  );
}

let Commandes = [];
const res2 = await axios.get("https://dummyjson.com/carts");
for (let Prod of res2.data.carts) {
  Commandes.push(Prod);
}

for (let i of Commandes) {
  const prods = i.products.map((product) => product.title);
  await session.run(
    `MATCH (u:User) WHERE u.id = ${i.userId}
       MERGE (u)-[:Placer]->(c:Commande {
         amount: "${i.total} DA",
         id: ${i.id}
       })`
  );

  for (let x of prods) {
    await session.run(
      `MATCH (c:Commande {id: ${i.id}})
         MATCH (p:Product {ProductName: "${x}"})
         CREATE (c)-[r:Contient]->(p)
         RETURN r`
    );
  }
}

await driver.close();

//Method N°01: Collaborative filtering
// v1:
match (u:User{id:5})
match (u)-[r:Placer]->(c:Commande)-[x:Contient]->(p:Product)
match (p)<-[Contient]-(w:Commande)<-[z:Placer]-(cli:User)
match (cli)-[:Placer]->(h:Commande)-[j:Contient]->(rec:Product)
return rec.ProductName as Titre, rec.ProductPrice as Prix , count(*) as Frequence order by Frequence Desc 
// v2:
match (u:User{id:5})
match (u)-[r:Placer]->(c:Commande)-[x:Contient]->(p:Product)
match (p)<-[Contient]-(w:Commande)<-[z:Placer]-(cli:User)
match (cli)-[:Placer]->(h:Commande)-[j:Contient]->(rec:Product)
where cli.id<>u.id
return rec.ProductName as Titre, rec.ProductPrice as Prix ,cli.id as idSource, u.id as idCible, count(*) as Frequence order by Frequence Desc 

//Method N°02: Using jaccard_index
match (u:User{id:5})
match (u)-[r:Placer]->(c:Commande)-[x:Contient]->(p:Product)
match (p)<-[Contient]-(w:Commande)<-[z:Placer]-(cli:User)
where cli.id<>u.id
with cli,u, COUNT(DISTINCT p) as intersection
match (c)-[r:Placer]->(c:Commande)-[x:Contient]->(p1:Product)
WHERE c in [cli, u]
WITH cli, u, intersection, COUNT(DISTINCT p1) as union
WITH cli, u, intersection, union, (intersection * 1.0 / union) as jaccard_index
ORDER BY jaccard_index DESC, cli.id
WITH u, COLLECT([cli.id, jaccard_index, intersection, union])[0..1] as neighbors
WHERE SIZE(neighbors) = 1
RETURN jaccard_index
//Method N°03: Content based filtering
// v1: with popularity
match (u:User{id:5})
match (u)-[r:Placer]->(c:Commande)-[x:Contient]->(p:Product)
match (p)-[:CategorisedBy]->(cat:Category)<-[: CategorisedBy]-(rec:Product)
match (rec)<-[:Contient]-(:Commande)
where rec.ProductName<>p.ProductName
return rec.ProductName as Titre, rec.ProductPrice as Prix ,cat.categoryName as Catégorie, count(*) as Frequence order by Frequence Desc 
// v2: without popularity
match (u:User{id:5})
match (u)-[r:Placer]->(c:Commande)-[x:Contient]->(p:Product)
match (p)-[:CategorisedBy]->(cat:Category)<-[: CategorisedBy]-(rec:Product)
where rec.ProductName<>p.ProductName
return rec.ProductName as Titre, rec.ProductPrice as Prix ,cat.categoryName as Catégorie

//Method N°04: Most popular products
match (u:User)
match (u)-[r:Placer]->(c:Commande)-[x:Contient]->(p:Product)-[:CategorisedBy]->(cat:Category)
return p.ProductName as Titre, p.ProductPrice as Prix ,cat.categoryName as Catégorie, count(*) as Frequence order by Frequence Desc 

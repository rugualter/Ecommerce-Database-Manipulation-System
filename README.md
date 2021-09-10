# Ecommerce-Database-Manipulation-System
Prolog - Ecommerce Database Manipulation System

An e-commerce database manipulation system in prolog application-based inventory and sales system, which allows you to check the list of customers, the purchases made by them and also the articles and respective inventory (stock and stockout notice). Is intended to record in Prolog, all relevant data in it in tables separate, such as: list of clients with name, city and credit_risk; list of articles with the indication of the reference, name and quantity_min_alerta; and finally, the list of inventory with reference and quantity indication.

1. Install swi-prolog for Windows (Recommendation: Cygwin https://www.cygwin.com/ )

2. Open Cygwin Terminal

3. Go to project folder
$ cd yourfolder

4. Compile and run the program
$ swipl ecommercemanipulation.pl

ATTENTION: THE DATA ENTERED IN THE PROGRAM MUST BE ATOMIC, THAT IS, YOU MUST FOLLOW THE PROLOG SYNTAX RULES ALL THE SENTENCES DON'T FORGET TO PUT THE END POINT

EXAMPLES: word -> word.
Word -> 'Word'.
word word -> 'word word'.

THE PROGRAM ALLOWS TO CALL THE PREDICATES IN SEVERAL WAYS TO FACILITATE THE USER, FOLLOW THE LIST:
	
	listar_cliente.	//list clients
	listar_cliente_bom.	//list good clients
	total_cliente_cidade.	//total clients by city
	total_cliente_cidade('city_name').	//clients of a specific city
	listar_cliente_vendas.	//list sales by client
	inventario_quantidade_stock.	//list stock inventory
	inventario_quantidade_stock(reference).	//list inventory stock by refrence
	inventario_quantidade_stock('name_article').	//list inventory stock by name
	artigo_verificar_abaixo_min_alerta.	//verify low stock articles
	artigo_verificar_abaixo_min_alerta(reference).	//verify low stock articles by reference
	artigo_verificar_abaixo_min_alerta('name_article').	//verify low stock articles by name
	venda_validar_artigo_cliente.	//validate sale
	venda_validar_artigo_cliente(reference, quantity, 'name_client').	//validate sale by reference
	venda_validar_artigo_cliente('name_article', quantity, 'name_client').	//validate sale by name
	inventario_atualiza_artigo.		//update stock
	inventario_atualiza_artigo(reference, quantity).	//update stock by refernce
	inventario_atualiza_artigo('name_article', quantity).	//update stock bt name
	venda_artigo_cliente.	//sell article
	venda_artigo_cliente(reference, quantity, 'name_client').	//sell article by reference
	venda_artigo_cliente('name_article', quantity, 'name_client').	//sell article by name
	inventario_relatorio.	//inventory report

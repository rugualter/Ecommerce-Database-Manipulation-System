/*------------------- Verssion ------------------------*/

%This version asks the user for data
%after running predicate without parameters

/*---------------------------------------------------*/

/*------------------- Staus of Facts------------------------*/
% sets the facts as changeable so we can manipulate the database data
:- dynamic(cliente/3).      
:- dynamic(artigo/3).
:- dynamic(inventario/2).
:- dynamic(vendas/3).

/* --------------------- predicates ---------------------------*/


%------------------------------------------------------------------------------------------
% List of all customers
%------------------------------------------------------------------------------------------
listar_cliente :-
    write('%%%%%%%%%%%%%%%%%% LISTA DE CLIENTES %%%%%%%%%%%%%%%%%'), nl, nl,
    forall(cliente(X,_,_), writeln(X)). %forall lists for all X writeln prints a newline

%------------------------------------------------------------------------------------------
% See customer list of customers with aaa credit risk
%------------------------------------------------------------------------------------------
listar_cliente_bom :-
    write('%%%%%%%%%%%%%%%%%% LISTA DE CLINTES BONS %%%%%%%%%%%%%%%%%'), nl, nl,
    forall(cliente(X,_,aaa), writeln(X)).

%------------------------------------------------------------------------------------------
% ----------------- View total number of customers for a particular city ------------------------
%------------------------------------------------------------------------------------------
total_cliente_cidade:-
    write('%%%%%%%%%%%%%%%%%% TOTAL DE CLINTES EM CIDADE %%%%%%%%%%%%%%%%%'), nl, nl,
    write('Insira o nome da cidade: '),
    read(Cidade),   %read reads user input
    aggregate_all(count, cliente(_,Cidade,_), Contagem), %aggregateall aggregates everything that is city and counts
    format('O total de Clintes em ~w é de ~w. ~n', [Cidade, Contagem]).

%----------------------------------------

total_cliente_cidade(Cidade) :- % Argument taking version
    write('%%%%%%%%%%%%%%%%%% TOTAL DE CLINTES EM CIDADE %%%%%%%%%%%%%%%%%'), nl, nl,
    aggregate_all(count, cliente(_,Cidade,_), Contagem), %aggregateall aggregates everything that is city and counts
    format('O total de Clintes em ~w é de ~w. ~n', [Cidade, Contagem]).

%------------------------------------------------------------------------------------------
% See list of customers to whom it was sold (no duplicates)
%------------------------------------------------------------------------------------------
listar_cliente_vendas :-
    write('%%%%%%%%%%%%%%%%%% LISTA DE CLIENTE A QUEM SE VENDEU %%%%%%%%%%%%%%%%%'), nl, nl,
    setof(X, X^Y^Z^vendas(X,Y,Z), Lista), % set of finds X with conditions X Y and Z and returns no duplicates
    write(Lista). % write prints

%------------------------------------------------------------------------------------------
% View stock by reference or name if there is no question quantity to add
%------------------------------------------------------------------------------------------
inventario_quantidade_stock :-
    write('%%%%%%%%%%%%%%%%%% OBTER QUANTIDADES DE INVENTÁRIO %%%%%%%%%%%%%%%%%'), nl, nl,
    write('Insira o nome ou referência do artigo: '),
    read(NomeOuReferencia),
    inventario_quantidade_stock_inicio(NomeOuReferencia). %calls a new predicate and passes the name or reference

inventario_quantidade_stock_inicio(Nome) :-  %if is name and has inventory show stock otherwise call another predicate to see if it is a reference
    artigo(X,Nome,Y), 
    inventario(X,Y) -> format('O Stock para o artigo de nome ~w é de ~w. ~n', [Nome, Y]) ; inventario_quantidade_ref(Nome). 

inventario_quantidade_ref(Referencia) :- %if the reference has inventory print stock if not call predicate to insert inventory
    inventario(Referencia,X) -> format('O Stock para o artigo de referencia ~w é de ~w. ~n', [Referencia, X]) ; inserir_inventario_ref(Referencia). 

inserir_inventario_ref(Referencia) :- %if reference asks to add inventory if not call new predicate to go to name
    artigo(Referencia,_,_) -> write('Artigo sem inventário. Insira a quantidade a adicionar:'), nl, read(X), assertz(inventario(Referencia,X)), format('Inventário de artigo de referencia ~w atualizado para ~w. ~n', [Referencia, X]) ; inserir_inventario_nome(Referencia).

inserir_inventario_nome(Nome) :- %if noe asks to add inventory if not says no article
    artigo(X,Nome,_) -> write('Artigo sem inventário. Insira a quantidade a adicionar:'), nl, read(Y), assertz(inventario(X,Y)), format('Inventário de artigo ~w atualizado para ~w. ~n', [Nome, Y]) ; write('ATENÇÃO: Artigo não existe'), nl.

%--------------------------------------

inventario_quantidade_stock(NomeOuReferencia) :- % Versao que recebe argumento
    write('%%%%%%%%%%%%%%%%%% OBTER QUANTIDADES DE INVENTÁRIO %%%%%%%%%%%%%%%%%'), nl, nl,
    refinventario_quantidade_stock_inicio(NomeOuReferencia). %calls a new predicate and passes the name or reference

refinventario_quantidade_stock_inicio(Nome) :-  %if is name and has inventory show stock otherwise call another predicate to see if it is a reference
    artigo(X,Nome,Y),
    inventario(X,Y) -> format('O Stock para o artigo de nome ~w é de ~w. ~n', [Nome, Y]) ; refinventario_quantidade_ref(Nome).

refinventario_quantidade_ref(Referencia) :- %if the reference has inventory print stock if not call predicate to insert inventory
    inventario(Referencia,X) -> format('O Stock para o artigo de referencia ~w é de ~w. ~n', [Referencia, X]) ; refinserir_inventario_ref(Referencia).

refinserir_inventario_ref(Referencia) :- %if reference asks to add inventory if not call new predicate to go to name
    artigo(Referencia,_,_) -> assertz(inventario(Referencia,0)), format('Inventário de artigo de referencia ~w atualizado para 0 pois não existia. ~n', [Referencia]) ; refinserir_inventario_nome(Referencia).

refinserir_inventario_nome(Nome) :- %if noe asks to add inventory if not says no article
    artigo(X,Nome,_) -> assertz(inventario(X,0)), format('Inventário de artigo ~w atualizado para 0 pois não existia. ~n', [Nome]) ; write('ATENÇÃO: Artigo não existe'), nl.

%------------------------------------------------------------------------------------------
% Check if the quantity of an item is below the limits and print messages
%------------------------------------------------------------------------------------------
artigo_verificar_abaixo_min_alerta :-
    write('%%%%%%%%%%%%%%%%%% ALTERTA DE STOCK MINIMO PARA ARTIGO %%%%%%%%%%%%%%%%%'), nl, nl,
    write('Insira o nome ou referência do artigo: '),
    read(NomeOuReferencia),
    artigo_verificar_abaixo_min_alerta_inicio(NomeOuReferencia). %calls a new predicate and passes the name or reference

artigo_verificar_abaixo_min_alerta_inicio(Nome) :-  %se is an article name call perfdicado to check alert if not call perfdicado to check if reference
    artigo(_,Nome,_) -> artigo_verificar_abaixo_min_alerta_nome(Nome) ; artigo_verificar_abaixo_min_alerta_intermedio(Nome).

artigo_verificar_abaixo_min_alerta_intermedio(Referencia) :- % if reference call perdicado to check alert if not then article does not exist
    artigo(Referencia,_,_) -> artigo_verificar_abaixo_min_alerta_ref(Referencia) ;  write('ATENÇÃO: Artigo não existe'), nl.

artigo_verificar_abaixo_min_alerta_ref(Referencia) :- % if reference checks if stock is less than alert quantity and prints messages
    artigo(Referencia,_,Y),
    inventario(Referencia,Z),
    Z<Y -> format('Atenção: Artigo com referência ~w com stock abaixo do limite mínimo. ~n', [Referencia]) ; format('Artigo com referência ~w com stock acima do limite mínimo. ~n', [Referencia]).

artigo_verificar_abaixo_min_alerta_nome(Nome) :- % if name checks if stock is less than alert amount and prints messages
    artigo(X,Nome,Y),
    inventario(X,Z),
    Z<Y -> format('Atenção: Artigo ~w com stock abaixo do limite mínimo. ~n', [Nome]) ; format('Artigo ~w com stock acima do limite mínimo. ~n', [Nome]).

%-------------------------------------------

artigo_verificar_abaixo_min_alerta(NomeOuReferencia) :- % Argument taking version
    write('%%%%%%%%%%%%%%%%%% ALTERTA DE STOCK MINIMO PARA ARTIGO %%%%%%%%%%%%%%%%%'), nl, nl,
    refartigo_verificar_abaixo_min_alerta_inicio(NomeOuReferencia). %calls a new predicate and passes the name or reference

    refartigo_verificar_abaixo_min_alerta_inicio(Nome) :- %se is an article name call perfdicado to check alert if not call perfdicado to check if reference
    artigo(_,Nome,_) -> refartigo_verificar_abaixo_min_alerta_nome(Nome) ; refartigo_verificar_abaixo_min_alerta_intermedio(Nome).

refartigo_verificar_abaixo_min_alerta_intermedio(Referencia) :- % if reference call perdicado to check alert if not then article does not exist
    artigo(Referencia,_,_) -> refartigo_verificar_abaixo_min_alerta_ref(Referencia) ;  write('ATENÇÃO: Artigo não existe'), nl.

refartigo_verificar_abaixo_min_alerta_ref(Referencia) :- % if reference checks if stock is less than alert quantity and prints messages
    artigo(Referencia,_,Y),
    inventario(Referencia,Z),
    Z<Y -> format('Atenção: Artigo com referência ~w com stock abaixo do limite mínimo. ~n', [Referencia]) ; format('Artigo com referência ~w com stock acima do limite mínimo. ~n', [Referencia]).

refartigo_verificar_abaixo_min_alerta_nome(Nome) :- % if name checks if stock is less than alert amount and prints messages
    artigo(X,Nome,Y),
    inventario(X,Z),
    Z<Y -> format('Atenção: Artigo ~w com stock abaixo do limite mínimo. ~n', [Nome]) ; format('Artigo ~w com stock acima do limite mínimo. ~n', [Nome]).

%------------------------------------------------------------------------------------------
% Check if there is quantity for sale in inventory and if the customer has a good risk position (aaa) incar success or failure
%------------------------------------------------------------------------------------------
venda_validar_artigo_cliente :-
    write('%%%%%%%%%%%%%%%%%% VALIDAÇÃO DE VENDA %%%%%%%%%%%%%%%%%'), nl, nl,
    write('Insira o nome ou referência do artigo: '),
    read(NomeOuReferencia),
    venda_validar_artigo_cliente_inicio(NomeOuReferencia).

venda_validar_artigo_cliente_inicio(NomeOuReferencia) :- % if it is an article name jumps to obtain quantities and comparison otherwise check if it is reference
    artigo(X,NomeOuReferencia,_) -> venda_validar_artigo_cliente_nome_artigo(NomeOuReferencia, X); venda_validar_artigo_cliente_referencia_artigo(NomeOuReferencia).

venda_validar_artigo_cliente_nome_artigo(Nome, Referencia) :- %Open the sales amount and check if there is an inventory, pass indicators if yes (1) or if not (0) to the next step
    write('Insira a quantidade a vender: '),
    read(Quantidade),
    inventario(Referencia,Y),
    Quantidade<Y -> venda_validar_artigo_cliente_nome_cliente(Nome,1) ; venda_validar_artigo_cliente_nome_cliente(Nome, 0).

venda_validar_artigo_cliente_referencia_artigo(Referencia) :- % if reference jumps to obtain quantities and comparison otherwise article does not exist
    artigo(Referencia,X,_) -> venda_validar_artigo_cliente_nome_artigo(X,Referencia) ;  write('ATENÇÃO: Artigo não existe'), nl.

venda_validar_artigo_cliente_nome_cliente(Nome, Validacao) :- %receives the name of the client checks the existence if it exists will call the predicate to validate the risk otherwise it informs that the client does not exist
    write('Insira o nome do Cliente: '),
    read(Cliente),
    cliente(Cliente,_,_) -> venda_validar_artigo_cliente_risco(Cliente, Nome, Validacao) ; write('ATENÇÃO: Cliente não existe'), nl.

venda_validar_artigo_cliente_risco(Cliente, Nome, Validacao) :- %verifies whether the client exists calls the success predicate or otherwise the failure predicate
    cliente(Cliente,_,aaa) -> venda_validar_artigo_cliente_mensagem_sucesso(Cliente, Nome, Validacao) ; venda_validar_artigo_cliente_mensagem_falha(Cliente, Nome, Validacao).

venda_validar_artigo_cliente_mensagem_falha(Cliente, Nome, Validacao) :- %uses previous stock validation to choose the right message
    Validacao == 1 -> format('FALHA: Existe inventário do artigo ~w suficiente para a venda ao cliente ~w mas este não tem uma boa posição no risco de crédito. ~n', [Nome, Cliente]) ; format('FALHA: Não existe inventário do artigo ~w suficiente para a venda ao cliente ~w e este não tem uma boa posição no rico de crédito. ~n', [Nome, Cliente]).

venda_validar_artigo_cliente_mensagem_sucesso(Cliente, Nome, Validacao) :-  %uses previous stock validation to choose the right message
    Validacao == 1 -> format('SUCESSO: O cliente ~w pode adquirir o artigo ~w. ~n', [Cliente, Nome]) ; format('FALHA: Não existe inventário do artigo ~w suficiente para a venda ao cliente ~w mas este tem uma boa posição no rico de crédito. ~n', [Nome, Cliente]).

%------------------------------------------------

venda_validar_artigo_cliente(NomeOuReferencia, Quantidade, Cliente) :- % Argument taking version
    write('%%%%%%%%%%%%%%%%%% VALIDAÇÃO DE VENDA %%%%%%%%%%%%%%%%%'), nl, nl,
    venda_validar_artigo_cliente_inicio(NomeOuReferencia, Quantidade, Cliente).

refvenda_validar_artigo_cliente_inicio(NomeOuReferencia, Quantidade, Cliente) :- % if it is an article name jumps to obtain quantities and comparison otherwise check if it is reference
    artigo(X,NomeOuReferencia,_) -> refvenda_validar_artigo_cliente_nome_artigo(NomeOuReferencia, X, Quantidade, Cliente); refvenda_validar_artigo_cliente_referencia_artigo(NomeOuReferencia, Quantidade, Cliente).

refvenda_validar_artigo_cliente_nome_artigo(Nome, Referencia, Quantidade, Cliente) :- %Open the sales amount and check if there is an inventory, pass indicators if yes (1) or if not (0) to the next step
    inventario(Referencia,Y),
    Quantidade<Y -> refvenda_validar_artigo_cliente_nome_cliente(Nome,1, Cliente) ; refvenda_validar_artigo_cliente_nome_cliente(Nome, 0, Cliente).

refvenda_validar_artigo_cliente_referencia_artigo(Referencia, Quantidade, Cliente) :- % if reference jumps to obtain quantities and comparison otherwise article does not exist
    artigo(Referencia,X,_) -> refvenda_validar_artigo_cliente_nome_artigo(X,Referencia, Quantidade, Cliente) ;  write('ATENÇÃO: Artigo não existe'), nl.

refvenda_validar_artigo_cliente_nome_cliente(Nome, Validacao, Cliente) :-  %receives the name of the client checks the existence if it exists will call the predicate to validate the risk otherwise it informs that the client does not exist
    cliente(Cliente,_,_) -> refvenda_validar_artigo_cliente_risco(Cliente, Nome, Validacao) ; write('ATENÇÃO: Cliente não existe'), nl.

refvenda_validar_artigo_cliente_risco(Cliente, Nome, Validacao) :- %verifies whether the client exists calls the success predicate or otherwise the failure predicate
    cliente(Cliente,_,aaa) -> refvenda_validar_artigo_cliente_mensagem_sucesso(Cliente, Nome, Validacao) ; refvenda_validar_artigo_cliente_mensagem_falha(Cliente, Nome, Validacao).

refvenda_validar_artigo_cliente_mensagem_falha(Cliente, Nome, Validacao) :- %uses previous stock validation to choose the right message
    Validacao == 1 -> format('FALHA: Existe inventário do artigo ~w suficiente para a venda ao cliente ~w mas este não tem uma boa posição no risco de crédito. ~n', [Nome, Cliente]) ; format('FALHA: Não existe inventário do artigo ~w suficiente para a venda ao cliente ~w e este não tem uma boa posição no rico de crédito. ~n', [Nome, Cliente]).

refvenda_validar_artigo_cliente_mensagem_sucesso(Cliente, Nome, Validacao) :- %uses previous stock validation to choose the right message
    Validacao == 1 -> format('SUCESSO: O cliente ~w pode adquirir o artigo ~w. ~n', [Cliente, Nome]) ; format('FALHA: Não existe inventário do artigo ~w suficiente para a venda ao cliente ~w mas este tem uma boa posição no rico de crédito. ~n', [Nome, Cliente]).


%------------------------------------------------------------------------------------------
% Update an article's inventory
%------------------------------------------------------------------------------------------
inventario_atualiza_artigo :-
    write('%%%%%%%%%%%%%%%%%% ATUALIZAR INVENTARIO %%%%%%%%%%%%%%%%%'), nl, nl,
    write('Insira o nome ou referência do artigo: '),
    read(NomeOuReferencia),
    inventario_atualiza_artigo_inicio(NomeOuReferencia).

inventario_atualiza_artigo_inicio(NomeOuReferencia) :- %checks if it is article name if it calls inventory update predicate xaso contraio calls reference
    artigo(X,NomeOuReferencia,_) ->  inventario_atualiza_artigo_verifica_referencia(X) ; inventario_atualiza_artigo_referencia(NomeOuReferencia).

inventario_atualiza_artigo_referencia(Referencia) :- % checks if it's a reference and calls update predicate otherwise the article doesn't exist
    artigo(Referencia,_,_) ->  inventario_atualiza_artigo_verifica_referencia(Referencia) ; write('ATENÇÃO: Artigo não existe'), nl.

inventario_atualiza_artigo_verifica_referencia(Referencia) :- %checks if there is already inventory data before calling the right type of addition or change
    inventario(Referencia,_) -> inventario_atualiza_artigo_atualiza_com_dados(Referencia) ; inventario_atualiza_artigo_atualiza_sem_dados(Referencia).

inventario_atualiza_artigo_atualiza_com_dados(Referencia) :- %updates the inventory by removing the current one and adding the new one
    write('Insira a quantidade a adicionar: '),
    read(Quantidade),
    retract(inventario(Referencia,_)),
    assertz(inventario(Referencia, Quantidade)),
    format('Inventário do artigo de referência ~w atualizado para ~w. ~n', [Referencia, Quantidade]).

inventario_atualiza_artigo_atualiza_sem_dados(Referencia) :- %updates inventory by adding
    write('Insira a quantidade a adicionar: '),
    read(Quantidade),
    assertz(inventario(Referencia, Quantidade)),
    format('Inventário do artigo de referência ~w atualizado para ~w. ~n', [Referencia, Quantidade]).

%-------------------------------------

inventario_atualiza_artigo(NomeOuReferencia, Quantidade) :- % Argument taking version
    write('%%%%%%%%%%%%%%%%%% ATUALIZAR INVENTARIO %%%%%%%%%%%%%%%%%'), nl, nl,
    refinventario_atualiza_artigo_inicio(NomeOuReferencia, Quantidade).

refinventario_atualiza_artigo_inicio(NomeOuReferencia, Quantidade) :- %checks if it is article name if it calls inventory update predicate xaso contraio calls reference
    artigo(X,NomeOuReferencia,_) ->  refinventario_atualiza_artigo_verifica_referencia(X, Quantidade) ; refinventario_atualiza_artigo_referencia(NomeOuReferencia, Quantidade).

refinventario_atualiza_artigo_referencia(Referencia, Quantidade) :- % checks if it's a reference and calls update predicate otherwise the article doesn't exist
    artigo(Referencia,_,_) ->  refinventario_atualiza_artigo_verifica_referencia(Referencia, Quantidade) ; write('ATENÇÃO: Artigo não existe'), nl.

refinventario_atualiza_artigo_verifica_referencia(Referencia, Quantidade) :- %checks if there is already inventory data before calling the right type of addition or change
    inventario(Referencia,_) -> refinventario_atualiza_artigo_atualiza_com_dados(Referencia, Quantidade) ; refinventario_atualiza_artigo_atualiza_sem_dados(Referencia, Quantidade).

refinventario_atualiza_artigo_atualiza_com_dados(Referencia, Quantidade) :- %updates the inventory by removing the current one and adding the new one
    retract(inventario(Referencia,_)),
    assertz(inventario(Referencia, Quantidade)),
    format('Inventário do artigo de referência ~w atualizado para ~w. ~n', [Referencia, Quantidade]).

refinventario_atualiza_artigo_atualiza_sem_dados(Referencia, Quantidade) :- %updates inventory by adding
    assertz(inventario(Referencia, Quantidade)),
    format('Inventário do artigo de referência ~w atualizado para ~w. ~n', [Referencia, Quantidade]).

%------------------------------------------------------------------------------------------
% Sells item to the customer asking for a customer an item and valid quantity, updates inventory and registers the sale
%------------------------------------------------------------------------------------------
venda_artigo_cliente :-
    write('%%%%%%%%%%%%%%%%%% VENDA AO CLINETE %%%%%%%%%%%%%%%%%'), nl, nl,
    write('Insira o nome ou referência do artigo: '),
    read(NomeOuReferencia),
    venda_artigo_cliente_inicio(NomeOuReferencia).

venda_artigo_cliente_inicio(NomeOuReferencia) :- % checks if it is item name if it calls predicate for quantity information or calls predicate to check if it is reference
    artigo(X,NomeOuReferencia,_) -> venda_artigo_cliente_nome_artigo(NomeOuReferencia, X); venda_artigo_cliente_referencia_artigo(NomeOuReferencia).

venda_artigo_cliente_nome_artigo(Nome, Referencia) :-   % ask for how much to sell, check if you have inventories, if yes, go on to ask for the customer's name if you don't say you don't have an inventory
    write('Insira a quantidade a vender: '),
    read(Quantidade),
    inventario(Referencia,Y),
    Quantidade<Y -> venda_artigo_cliente_nome_cliente(Quantidade, Nome, Referencia) ;  format('FALHA: Não existe inventário do artigo ~w suficiente para a venda ao cliente. ~n', [Nome]).

venda_artigo_cliente_referencia_artigo(Referencia) :- %checks if the reference exists if yes calls the predicate to put the amount to sell if it doesn't say that the product doesn't exist
    artigo(Referencia,X,_) -> venda_artigo_cliente_nome_artigo(X,Referencia) ;  write('ATENÇÃO: Artigo não existe'), nl.

venda_artigo_cliente_nome_cliente(Quantidade, Nome, Referencia) :- %receives client name checks if there is a predicate call to check risk if it does not warn that there is no client
    write('Insira o nome do Cliente: '),
    read(Cliente),
    cliente(Cliente,_,_) -> venda_artigo_cliente_risco(Quantidade, Cliente, Nome, Referencia) ; write('ATENÇÃO: Cliente não existe'), nl.

venda_artigo_cliente_risco(Quantidade, Cliente, Nome, Referencia) :- %checks if the risk is aaa if it is called predicate
    cliente(Cliente,_,aaa) -> venda_artigo_cliente_sucesso_risco(Quantidade, Cliente, Nome, Referencia) ; format('FALHA: O cliente ~w não tem uma boa posição no risco de crédito. ~n', [Cliente]).

venda_artigo_cliente_sucesso_risco(Quantidade, Cliente, Nome, Referencia) :- %checks if there is already a customer sale on these products, forwards it to the correct function
    inventario(Referencia,X),
    Y is X-Quantidade,
    retract(inventario(Referencia,_)),
    assertz(inventario(Referencia, Y)),
    vendas(Cliente,Referencia,_) -> venda_artigo_cliente_vendas_com_dados(Quantidade, Cliente, Nome, Referencia) ; venda_artigo_cliente_vendas_sem_dados(Quantidade, Cliente, Nome, Referencia). 

venda_artigo_cliente_vendas_com_dados(Quantidade, Cliente, Nome, Referencia) :- %insert in sales list
    vendas(Cliente,Referencia,X),
    Y is X + Quantidade,
    retract(vendas(Cliente,Referencia,_)),
    assertz(vendas(Cliente,Referencia,Y)),
    format('VENDIDO: O cliente ~w comprou ~w unidades do(s) artigo(s) ~w. ~n', [Cliente, Quantidade, Nome]).

venda_artigo_cliente_vendas_sem_dados(Quantidade, Cliente, Nome, Referencia) :-  %insere na lista de vendas
    assertz(vendas(Cliente,Referencia,Quantidade)),
    format('VENDIDO: O cliente ~w comprou ~w unidades do(s) artigo(s) ~w. ~n', [Cliente, Quantidade, Nome]).

%---------------------------------------------

venda_artigo_cliente(NomeOuReferencia, Quantidade, Cliente) :-
    write('%%%%%%%%%%%%%%%%%% VENDA AO CLINETE %%%%%%%%%%%%%%%%%'), nl, nl,
    refvenda_artigo_cliente_inicio(NomeOuReferencia, Quantidade, Cliente).

refvenda_artigo_cliente_inicio(NomeOuReferencia, Quantidade, Cliente) :-  % checks if it is item name if it calls predicate for quantity information or calls predicate to check if it is reference
    artigo(X,NomeOuReferencia,_) -> refvenda_artigo_cliente_nome_artigo(NomeOuReferencia, X, Quantidade, Cliente); refvenda_artigo_cliente_referencia_artigo(NomeOuReferencia, Quantidade, Cliente).

refvenda_artigo_cliente_nome_artigo(Nome, Referencia, Quantidade, Cliente) :- % ask for how much to sell, check if you have inventories, if yes, go on to ask for the customer's name if you don't say you don't have an inventory
    inventario(Referencia,Y),
    Quantidade<Y -> refvenda_artigo_cliente_nome_cliente(Quantidade, Nome, Referencia, Quantidade, Cliente) ;  format('FALHA: Não existe inventário do artigo ~w suficiente para a venda ao cliente. ~n', [Nome]).

refvenda_artigo_cliente_referencia_artigo(Referencia, Quantidade, Cliente) :- %checks if the reference exists if yes calls the predicate to put the amount to sell if it doesn't say that the product doesn't exist
    artigo(Referencia,X,_) -> refvenda_artigo_cliente_nome_artigo(X,Referencia, Quantidade, Cliente) ;  write('ATENÇÃO: Artigo não existe'), nl.

refvenda_artigo_cliente_nome_cliente(Quantidade, Nome, Referencia, Quantidade, Cliente) :- %receives client name checks if there is a predicate call to check risk if it does not warn that there is no client
    cliente(Cliente,_,_) -> refvenda_artigo_cliente_risco(Quantidade, Cliente, Nome, Referencia) ; write('ATENÇÃO: Cliente não existe'), nl.

refvenda_artigo_cliente_risco(Quantidade, Cliente, Nome, Referencia) :- %checks if the risk is aaa if it is called predicate
    cliente(Cliente,_,aaa) -> refvenda_artigo_cliente_sucesso_risco(Quantidade, Cliente, Nome, Referencia) ; format('FALHA: O cliente ~w não tem uma boa posição no risco de crédito. ~n', [Cliente]).

refvenda_artigo_cliente_sucesso_risco(Quantidade, Cliente, Nome, Referencia) :- %checks if there is already a customer sale on these products, forwards it to the correct function
    inventario(Referencia,X),
    Y is X-Quantidade,
    retract(inventario(Referencia,_)),
    assertz(inventario(Referencia, Y)),
    vendas(Cliente,Referencia,_) -> refvenda_artigo_cliente_vendas_com_dados(Quantidade, Cliente, Nome, Referencia) ; refvenda_artigo_cliente_vendas_sem_dados(Quantidade, Cliente, Nome, Referencia). 

refvenda_artigo_cliente_vendas_com_dados(Quantidade, Cliente, Nome, Referencia) :-  %insere na lista de vendas
    vendas(Cliente,Referencia,X),
    Y is X + Quantidade,
    retract(vendas(Cliente,Referencia,_)),
    assertz(vendas(Cliente,Referencia,Y)),
    format('VENDIDO: O cliente ~w comprou ~w unidades do(s) artigo(s) ~w. ~n', [Cliente, Quantidade, Nome]).

refvenda_artigo_cliente_vendas_sem_dados(Quantidade, Cliente, Nome, Referencia) :-  %insere na lista de vendas
    assertz(vendas(Cliente,Referencia,Quantidade)),
    format('VENDIDO: O cliente ~w comprou ~w unidades do(s) artigo(s) ~w. ~n', [Cliente, Quantidade, Nome]).

%------------------------------------------------------------------------------------------
% Print inventory report for all items.
%------------------------------------------------------------------------------------------
inventario_relatorio :-
    forall((artigo(X,Y,_),inventario(X,Z)), format('Referência: ~w ~5t Artigo: ~w ~5t Stock: ~w. ~5t ~n', [X, Y, Z])).


/*-------------------------Database --------------------------*/

% database I use atoms as they are simpler as the string generates a list of characters that is not needed here
cliente('Daniel','Funchal',xxx).
cliente('David','Aveiro',aaa).
cliente('Rui','Aveiro',bbb).
cliente('Julia','Leiria',aaa).
cliente('Jose','Caldas da Rainha',aaa).
cliente('Tomas','Coimbra',ccc).
cliente('Americo','Sintra',bbb).

artigo(a1,rato_otico,10).
artigo(a2,'teclado s fios',10).
artigo(a3,'LCD_15',10).
artigo(a4,'Portátil_zen_5013',10).
artigo(a5,'Portátil_zen_5050',10).
artigo(a6,pen_512Mb_blue,10).
artigo(a7,'disco externo 2Gb',10).
artigo(a8,'disco externo 2Gb',10).

inventario(a1,10).
inventario(a2,10).
inventario(a3,10).
inventario(a4,78).
inventario(a5,23).
inventario(a6,14).
inventario(a7,8).

vendas('Daniel',a1,12).
vendas('Americo','A1',1).
vendas('Americo',a3,1).
vendas('Joao',a1,12).
vendas('Daniel',as,12).
vendas('Andre',a1,12).
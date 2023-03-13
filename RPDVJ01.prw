#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "aarray.ch"
#INCLUDE "json.ch"
#include "topconn.ch"
#include "tbiconn.ch"                                      

/*
#define SW_HIDE 0 // Escondido
#define SW_SHOWNORMAL 1 // Normal
#define SW_NORMAL 1 // Normal
#define SW_SHOWMINIMIZED 2 // Minimizada
#define SW_SHOWMAXIMIZED 3 // Maximizada
#define SW_MAXIMIZE 3 // Maximizada
#define SW_SHOWNOACTIVATE 4 // Na Ativação
#define SW_SHOW 5 // Mostra na posição mais recente da janela
#define SW_MINIMIZE 6 // Minimizada
#define SW_SHOWMINNOACTIVE 7 // Minimizada
#define SW_SHOWNA 8 // Esconde a barra de tarefas
#define SW_RESTORE 9 // Restaura a posição anterior
#define SW_SHOWDEFAULT 10// Posição padrão da aplicação
#define SW_FORCEMINIMIZE 11// Força minimização independente da aplicação executada
#define SW_MAX 11// Maximizada
*/
#DEFINE ENTER CHR(13)+CHR(10)
#DEFINE NOT_SYNCHRONIZED "0"
#DEFINE SYNCHRONIZED "1"
#DEFINE PROTHEUS_SYNC "2"
#DEFINE PROTHEUS_REJECTED "3"
#DEFINE PROTHEUS_INVOICE "4"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RPDVJ01  ºAutor  ³Fabio Simonetti     º Data ³  17/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Integracao Mailer Protheus                                 º±±
±±º			 ³ Processa a abertura de emails e links das campanhas		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IndigoPDV                                               	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RPDVJ01(aParam) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpca          := 0
Local aSays          := {}
Local aButtons       := {}
Local cCadastro      := OemToAnsi("Verifica a interface do IndigoPDV e sube as alterações")
Local aArea          := {}
Private lJob         := .F.
Default aParam       := {.F.}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina a execucao via job                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lJob := aParam[1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica conexao de internet	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !u_verifyInternet(lJob)
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara o ambiente dependendo do modo de execucao                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lJob
     PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" FUNNAME FunName() TABLES "SC5", "SC9", "SC6"
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - Verificando interface do PDV (RPDVJ01) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Processa o envio do email                                                 ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     PDVInterface()

     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Finaliza o ambiente                                                       ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     ConOut(Repl("-",100))
     ConOut(Padc("Finalizando Job Verificando interface do PDV (RPDVJ01) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))
     RESET ENVIRONMENT
Else
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Monta tela principal                                                      ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     AADD(aSays,OemToAnsi("Verificando interface do PDV (RPDVJ01) ==> "                           ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aButtons, { 1,.T.                              ,{|o| (PDVInterface(),o:oWnd:End())     }})
     AADD(aButtons, { 2,.T.                              ,{|o| o:oWnd:End()                     }})
     FormBatch( cCadastro, aSays, aButtons )
Endif
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ RdMake   ³CallEMails³ Autor ³ Fabio Simonetti       ³ Data ³ 10/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PDVInterface()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lJob        
     procPDV()
Else
     U_IndProcess({|| procPDV() },"Processando...")
Endif
Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºProgram   ³PDVInterface ºAuthor ³Fabio Simonetti     º Date ³  17/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcoes comuns e genericas de utilizacao dos portais          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ³ Funcionalidade alterada ou incluida                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function procPDV()
Local cNumPed	:= ""
Local cCodProd	:= ""
Local lErro     := .T.
Local lGravaOk	:= .F.
Local lLiber 	:= .T.
Local lTransf	:= .F.
Local x			:= 0
Local y			:= 0
Local aUpdFields:= {}
Local aQryFields:= {}

Private aGets   := Array(0)
Private aTela   := Array(0,0)
Private aHeader := Array(0)
Private aCols   := Array(0)
Private aaOrdersAvailable := NIL
Public Inclui  := .T.

dbSelectArea("SB1")
SB1->(dbSetOrder(1)) //B1_FILIAL + B1_COD

dbSelectArea("SA1")
SA1->(dbSetOrder(1)) //A1_FILIAL + A1_COD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader para a rotina a410Grava                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SC6")
While !Eof() .And. SX3->X3_ARQUIVO == "SC6"
    Aadd(aHeader,{ 	AllTrim(X3Titulo()),;
							SX3->X3_CAMPO	,;
							SX3->X3_PICTURE,;
							SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,;
							SX3->X3_VALID	,;
							SX3->X3_USADO	,;
							SX3->X3_TIPO	,;
							SX3->X3_ARQUIVO,;
							SX3->X3_CONTEXT })
	DbSelectArea("SX3")
	DbSkip()
Enddo

cSessionToken := u_GetToken()

If Empty(cSessionToken)
	If lJob
		ConOut("Problemas ao obter o SessionToken no fonte RPDVJ01")
	Else	
		Aviso("Aviso","Não foi possivel obter o SessionToken para comunicação com o Mobile.",{"Ok"},2)
	EndIf
EndIf

aAdd(aQryFields,{"sync_status","1",.F.})
aaOrdersAvailable := u_queryNaInterface(cSessionToken, "SC5",aQryFields,lJob)

/*
order/pedido -> sync_status

0 - Cinza -> não sincronizado
1 - Amarelo -> sincronizado com o Parse
2 - Verde -> sincronizado com o Protheus
3 - Vermelho -> Rejeitado (erro)
4 - Azul -> Faturado
*/

If Len(aaOrdersAvailable:Get("results")) == 0
	If lJob
		Conout("IndigoPDV - Não foi encontrado nenhum pedido na interface do PDV")
	Else
		MsgInfo("Não foi encontrado nenhum pedido na interface do PDV")
	Endif
Else
	If !lJob
		U_IndigoReg(Len(aaOrdersAvailable:Get("results")))
	Else
		Conout("IndigoPDV - Encontrado novos pedidos para importacao: "+cValTochar(Len(aaOrdersAvailable:Get("results"))))
	Endif
Endif

For x := 1 To Len(aaOrdersAvailable:Get("results"))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o Status									   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lJob
		U_IndigoPrc("Processando: "+cValToChar(x)+"/"+cValTochar(Len(aaOrdersAvailable:Get("results"))))
	Else
		Conout("Processando: "+cValToChar(x)+"/"+cValTochar(Len(aaOrdersAvailable:Get("results"))))
    Endif
	If aaOrdersAvailable:Get("results")[x]:get("sync_status") == SYNCHRONIZED
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona nos arquivos necessários                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		dbSetOrder(3)
		If !Empty(aaOrdersAvailable:Get("results")[x]:get("customer_id"))
			SA1->(dbSeek(xFilial("SA1")+aaOrdersAvailable:Get("results")[x]:get("customer_id"))) // Tratar gravacao de cliente
			Conout("Cliente Encontrado: "+SA1->(A1_COD+A1_LOJA)+" Nome:"+AllTrim(SA1->A1_NOME))
		Else
			//SA1->(dbSeek(xFilial("SA1")+"000039"+"01")) //CONSUMIDOR
			//Conout("Cliente Não Encontrado, utilizando cliente generico, pedido: "+aaOrdersAvailable:Get("results")[x]:get("order_number_id"))
			//todo TESTAR
			//aQryFields := {}
			//aAdd(aQryFields,{"company_id",aaOrdersAvailable:Get("results")[x]:get("customer_id")},.F.})
			//aaCustomers := u_queryNaInterface("SA1",aQryFields,lJob)
			//If Len(aaCustomers:Get("results")) == 0
			
			//Endif

		Endif
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa desta forma para criar uma nova instancia de variaveis private           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RegToMemory( "SC5", .T. ) 
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o numero do pedido de venda existe                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cNumPed	:= GetSxeNum("SC5","C5_NUM")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona os dados de cabecalho						   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dDTEmissao := StoD(StrTran(Left(aaOrdersAvailable:Get("results")[x]:get("order_date"):get("iso"),10),"-",""))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o cabecalho do pedido de venda                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->C5_FILIAL 	:= xFilial("SC5")
		M->C5_NUM 		:= cNumPed
		M->C5_TIPO		:= "N"
		M->C5_CLIENTE	:= SA1->A1_COD
		M->C5_LOJACLI	:= SA1->A1_LOJA
		M->C5_CLIENT	:= SA1->A1_COD
		M->C5_LOJAENT	:= SA1->A1_LOJA
		M->C5_TIPOCLI	:= SA1->A1_TIPO
		M->C5_TRANSP	:= SA1->A1_TRANSP
		//M->C5_CONDPAG	:= 
		If Type('aaOrdersAvailable:Get("results")[x]:get("payment_type")') == "C"
			M->C5_TABELA	:= aaOrdersAvailable:Get("results")[x]:get("payment_type")
		Else
			M->C5_TABELA	:= "001"
		Endif
		cVend 		:= ""
		cNameVend	:= ""
		SA3->(dbSetOrder(1))
		If SA3->(dbSeek(xFilial("SA3")+AllTrim(aaOrdersAvailable:Get("results")[1]:get("seller_id"))))
			cVend 		:= SA3->A3_COD
			cNameVend	:= SA3->A3_NOME
		EndIf
		M->C5_MOEDA		:= 1                                `
		M->C5_EMISSAO	:= dDataBase
		M->C5_MENNOTA	:= ""
		M->C5_TIPLIB	:= "1"
		M->C5_VEND1     := SA1->A1_VEND
		M->C5_TIPOCLI 	:= "F"
		M->C5_PDVID 	:= aaOrdersAvailable:Get("results")[x]:get("objectId")
		M->C5_PDVNUM 	:= aaOrdersAvailable:Get("results")[x]:get("order_number_id")
		M->C5_PDVUSR  	:= cVend 
		M->C5_PDVNUSR 	:= cNameVend 
		M->C5_PDVSYNC 	:= aaOrdersAvailable:Get("results")[x]:get("sync_status")
		If !Empty(aaOrdersAvailable:Get("results")[x]:get("customer_name"))
			M->C5_PDVCUSN 	:= aaOrdersAvailable:Get("results")[x]:get("customer_name")
		Endif
		If !Empty(aaOrdersAvailable:Get("results")[x]:get("customer_id"))
			M->C5_PDVCUSI  	:= aaOrdersAvailable:Get("results")[x]:get("customer_id") //CPNJ
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica os itens do pedido							   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cOrderNum := aaOrdersAvailable:Get("results")[x]:get("order_number_id")
		
		aaItensOrder := u_queryNaInterface(cSessionToken,"SC6",{{"order_number_id",cOrderNum,.F.},{"seller_id",cVend,.F.}},lJob)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array dos itens com as informações do arquio TXT                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols	:= {}
		
		If Len(aaItensOrder:Get("results")) == 0
			Conout("IndigoPDV - Não foi encontrado item para este pedido: "+cOrderNum)
		Else
			Conout("IndigoPDV - Encontrado(s) "+cValTochar(Len(aaItensOrder:Get("results")))+" itens no pedido: "+cOrderNum)
		Endif
		
		For y := 1 To Len(aaItensOrder:Get("results"))
			If cVend <> aaItensOrder:Get("results")[y]:get("seller_id")
				Loop
			EndIf
			aAdd(aCols,Array(Len(aHeader)+1))
			aCols[Len(aCols),Len(aHeader)+1] 											:= .F.
			aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_FILIAL"})]	 	:= xFilial("SC6")
			aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_ITEM"})]	   	:= aaItensOrder:Get("results")[y]:get("order_item")
			
			cCodProd := aaItensOrder:Get("results")[y]:get("product_id")
			If ValType(cCodProd) == "C" 
				If !SB1->(dbSeek(xFilial("SB1")+cCodProd ))
					SB1->(dbSeek(xFilial("SB1")+"NAODEF" ))
					Conout("IndigoPDV - Não foi encontrado o produto: "+aaItensOrder:Get("results")[y]:get("product_id")+" Utilizando um generico")
				Endif
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_PRODUTO"})]	:= SB1->B1_COD
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_DESCRI"})] 	:= SB1->B1_DESC
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_UM"})] 		:= SB1->B1_UM
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_LOCAL"})] 		:= SB1->B1_LOCPAD
				
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_QTDVEN"})] 	:= aaItensOrder:Get("results")[y]:get("quantity")
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_PRCVEN"})] 	:= aaItensOrder:Get("results")[y]:get("price")
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_VALOR"})]  	:= aaItensOrder:Get("results")[y]:get("total_price")
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_QTDLIB"})] 	:= aaItensOrder:Get("results")[y]:get("quantity")
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_SEGUM"})] 		:= SB1->B1_UM
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_QTDLIB2"})]	:= 0
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_TES"})]	 	:= "501"
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_PDVID"})]	 	:= aaItensOrder:Get("results")[y]:get("objectId")
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_PDVNUM"})]	 	:= aaItensOrder:Get("results")[y]:get("order_number_id")
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_RATEIO"})]	 	:= "2"
				
				If !Empty(aaOrdersAvailable:Get("results")[x]:get("customer_code"))
					aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_CLI"})]	:= aaOrdersAvailable:Get("results")[x]:get("customer_code")
				Else
					aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_CLI"})]	:= "999999"
				Endif
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_LOJA"})]	 	:= "01"
					
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_ENTREG"})]	 	:= dDTEmissao //TODO - Melhoria
				aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_SUGENTR"})]	:= dDTEmissao //TODO - Melhoria
					
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acerta os campos nulos do array                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nLoop1 := 1 to Len(aHeader)
					If aCols[Len(aCols),nLoop1] == NIL
						aCols[Len(aCols),nLoop1]	:= CriaVar(aHeader[nLoop1,2],.f.)
					Endif   
				Next nLoop1
			Endif	
		Next
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se tem conteudo a ser gravado                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		If Len(aCols) > 0
			lGravaOk := .F.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravando o pedido de venda                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Begin Transaction
				lGravaOk := A410Grava(lLiber,lTransf)
				If !lGravaOk
					If __lSX8
						RollBackSX8()
					EndIf
					DisarmTransaction()
					If lJob
						Conout("IndigoPDV - Ocorreu um erro na geração do pedido, reinicie a operação")
					Else
						MsgAlert("Ocorreu um erro na geração do pedido, reinicie a operação")
					Endif
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Guarda os pedidos gerados para mostrar a mensagem                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//cStrPed	+= If(!Empty(cStrPed),"/","")+cNumPed
					If __lSX8
						ConfirmSX8()
				 	EndIf
				 	MsUnlockAll()
				 	DbCommitAll()
				Endif
			End Transaction
		
			If lGravaOk
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inclusao do pedido de venda pelo execauto do MATA410   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lJob
					Conout("IndigoPDV - Pedido Gerado com sucesso! Pedido: "+cNumPed)
				Else
					Msginfo("Pedido Gerado com sucesso! Pedido: "+cNumPed)
				Endif	
				
			 	u_xAtualizarNaInterface(cSessionToken,"SC5", AllTrim(SC5->C5_PDVID), {{"sync_status",cValTochar(PROTHEUS_SYNC)},{"protheus_id",cNumPed}}, lJob)
			EndIf
		Endif	
	Endif
Next

Return
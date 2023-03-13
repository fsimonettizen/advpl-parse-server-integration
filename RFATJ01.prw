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
#DEFINE NOT_SYNCHRONIZED 0
#DEFINE SYNCHRONIZED 1
#DEFINE PROTHEUS_SYNC 2
#DEFINE PROTHEUS_REJECTED 3
#DEFINE PROTHEUS_INVOICE 4

Static nHandURL := 0
Static nHandHTML := 0
Static oMeter, nAtual, nBmp, oText
Static nTotal, nMeterDif
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Prepara o ambiente dependendo do modo de execucao                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lJob
     PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" FUNNAME FunName() TABLES "SC5", "SC9", "SC6"
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
Local aHeadOut 	:= {}
Local cParPost 	:= ""
Local aHeadOut 	:= {}
Local cHeadRet 	:= ""
Local sGetRet  	:= ""
Local cNumPed	:= ""
Local cCodProd	:= ""
Local lErro     := .T.
Local lGravaOk	:= .F.
Local lLiber 	:= .T.
Local lTransf	:= .F.
Private aGets   := Array(0)
Private aTela   := Array(0,0)
Private aHeader := Array(0)
Private aCols   := Array(0)
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

aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
aadd(aHeadOut,"Content-Type: application/x-www-form-urlencoded")
aAdd(aHeadOut,"X-Parse-Application-Id: <Parse-Application-Id>")
aAdd(aHeadOut,"X-Parse-REST-API-Key: <Parse-REST-API-Key>")

aaOrdersAvailable := u_FromJson(HttpsGet("https://api.parse.com/1/classes/order_head/","", "", "", 'where={"sync_status":"1"}',120,aHeadOut,@cHeadRet))

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
	If aaOrdersAvailable:Get("results")[x]:get("sync_status") == "1"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona nos arquivos necessários                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		dbSetOrder(1)
		If !Empty(aaOrdersAvailable:Get("results")[x]:get("customer_code"))
			SA1->(dbSeek(xFilial("SA1")+aaOrdersAvailable:Get("results")[x]:get("customer_code")+"01"))
			Conout("Cliente Encontrado: "+SA1->(A1_COD+A1_LOJA)+" Nome:"+AllTrim(SA1->A1_NOME))
		Else
			SA1->(dbSeek(xFilial("SA1")+"999999"+"01"))
			Conout("Cliente Não Encontrado, utilizando cliente generico, pedido: "+aaOrdersAvailable:Get("results")[x]:get("order_number_id"))
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
		M->C5_TABELA	:= "001" //aaOrdersAvailable:Get("results")[x]:get("payment_type")
		M->C5_MOEDA		:= 1                                `
		M->C5_EMISSAO	:= dDataBase
		M->C5_MENNOTA	:= ""
		M->C5_TIPLIB	:= "1"
		M->C5_VEND1     := SA1->A1_VEND
		M->C5_TIPOCLI 	:= "F"
		M->C5_PDVID 	:= aaOrdersAvailable:Get("results")[x]:get("objectId")
		M->C5_PDVNUM 	:= UsrFullName(aaOrdersAvailable:Get("results")[x]:get("user_protheus_id"))
		//M->C5_PDVUSR  	:= aaOrdersAvailable:Get("results")[x]:get("user_protheus_id")
		M->C5_PDVNUSR 	:= aaOrdersAvailable:Get("results")[x]:get("objectId")
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
		aaItensOrder := u_FromJson(HttpsGet("https://api.parse.com/1/classes/order_item/","", "", "", 'where={"order_number_id":"'+cOrderNum+'"}',120,aHeadOut,@cHeadRet))
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta array dos itens com as informações do arquio TXT                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols	:= {}
		
		If Len(aaItensOrder:Get("results")) == 0
			Conout("IndigoPDV - Não foi encontrado item para este pedido: "+aaOrdersAvailable:Get("results")[x]:get("order_number_id"))
		Else
			Conout("IndigoPDV - Encontrado "+cValTochar(Len(aaOrdersAvailable:Get("results")))+" itens no pedido: "+aaOrdersAvailable:Get("results")[x]:get("order_number_id"))
		Endif
		
		For y := 1 To Len(aaItensOrder:Get("results"))
			aAdd(aCols,Array(Len(aHeader)+1))
			aCols[Len(aCols),Len(aHeader)+1] 											:= .F.
			aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_FILIAL"})]	 	:= xFilial("SC6")
			aCols[Len(aCols),aScan(aHeader, { |x| AllTrim(x[2]) == "C6_ITEM"})]	   	:= aaItensOrder:Get("results")[y]:get("order_item")
			
			cCodProd := aaItensOrder:Get("results")[y]:get("product_id")
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
				lUpdated := .F.
				
				While !lUpdated
					cCmd := 'curl -X PUT -H "X-Parse-Application-Id: <Parse-Application-Id>"'+;
						   ' -H "X-Parse-REST-API-Key: <Parse-REST-API-Key>"'+;
						   ' -H "Content-Type: application/json"'+;
						   ' -d "'+'{\"sync_status\":\"'+cValTochar(PROTHEUS_SYNC)+'\"}'+'" '+;
						   ' https://api.parse.com/1/classes/order_head/'+AllTrim(SC5->C5_PDVID)
					If lJob	   
						WaitRunSrv( "C:\Documents and Settings\Admin\Local Settings\Application Data\Apps\cURL\bin\"+cCmd,;
						.F.,;
						"C:\Documents and Settings\Admin\Local Settings\Application Data\Apps\cURL\bin")
					Else				
						winexec(cCmd,0)
					Endif
							
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica o Status se foi alterado					   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aaOrdersUpdated := u_FromJson(HttpsGet("https://api.parse.com/1/classes/order_head/"+AllTrim(SC5->C5_PDVID),"", "", "", '',120,aHeadOut,@cHeadRet))
					
					If aaOrdersUpdated:Get("sync_status") == cValTochar(PROTHEUS_SYNC)
						lUpdated := .T.
						If lJob	
							Conout("IndigoPDV - Pedido atualizado com sucesso! "+SC5->C5_NUM)
						Endif
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ espera talvez problema de oscilacao					   ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Sleep(1500)	
						If lJob	
							Conout("IndigoPDV - Pedido Não atualizado... "+SC5->C5_NUM)
						Endif
					Endif
				Enddo
			EndIf
		Endif	
	Endif
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IndigoProcess ºAutor  ³Fabio Simonetti     º Data ³  22/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Processamento Indigo                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function IndProcess( bAction, cTitle ,cMsg,lAbort)

Local oDlg, oTimer, oBMP
Local lEnd := .f.
Local nVal := 0
Local aSaves := {}
Local cSepPasta     := If(IsSrvUnix() .And. GetRemoteType() == 1,"/","\")

AADD(aSaves,oMeter)
AADD(aSaves,nAtual)
AADD(aSaves,nBMP)
AADD(aSaves,otext)
AADD(aSaves,nTotal)
AADD(aSaves,nMeterDif)

nAtual:= 0
nMeterDif:= 0

DEFAULT bAction := { || nil }, cMsg := "Processando...", cTitle := "Aguarde" //
DEFAULT lAbort := .f.

If cVersao == "10"
	DEFINE MSDIALOG oDlg FROM 0,0 TO 160,300 TITLE OemToAnsi(cTitle) STYLE DS_MODALFRAME STATUS PIXEL
	
	TBitmap():New(05,40,100,100,,GetSrvProfString("Startpath","")+"indigo\indigo.png",.T.,oDlg,,,,.F.,,,,,.T.)
	
	@ 35,10 SAY oText VAR cMsg SIZE 135,10 OF oDlg FONT oDlg:oFont PIXEL
	@ 45,10 METER oMeter VAR nVal TOTAL 10 SIZE 143, 10 OF oDlg BARCOLOR GetSysColor(13),GetSysColor() PIXEL
	IF lAbort
		DEFINE SBUTTON FROM 66,120 TYPE 2 ACTION (lAbortPrint := .t.,lEnd := .t.) ENABLE OF oDlg PIXEL
	Else
		DEFINE SBUTTON FROM 66,120 TYPE 2 OF oDlg PIXEL
	Endif
	oDlg:bStart:= { || Eval( bAction, @lEnd ),lEnd := .t., oDlg:End() }
	ACTIVATE DIALOG oDlg VALID lEnd CENTERED
Else
	DEFINE MSDIALOG oDlg FROM 0,0 TO 150,300 TITLE OemToAnsi(cTitle) STYLE DS_MODALFRAME STATUS PIXEL
	
	TBitmap():New(05,40,100,100,,GetSrvProfString("Startpath","")+"indigo\indigo.png",.T.,oDlg,,,,.F.,,,,,.T.)
	
	@ 40,10 SAY oText VAR cMsg SIZE 135,10 OF oDlg FONT oDlg:oFont PIXEL
	@ 50,10 METER oMeter VAR nVal TOTAL 10 SIZE 130, 10 OF oDlg BARCOLOR GetSysColor(13),GetSysColor() PIXEL
	IF lAbort
		DEFINE SBUTTON FROM 64,120 TYPE 2 ACTION (lAbortPrint := .t.,lEnd := .t.) ENABLE OF oDlg PIXEL
	Else
		DEFINE SBUTTON FROM 64,120 TYPE 2 OF oDlg PIXEL
	Endif
	oDlg:bStart:= { || Eval( bAction, @lEnd ),lEnd := .t., oDlg:End() }
	ACTIVATE DIALOG oDlg VALID lEnd CENTERED
Endif
oMeter := aSaves[1]
nAtual := aSaves[2]
nBMP := aSaves[3]
oText := aSaves[4]
nTotal := aSaves[5]
nMeterDif := aSaves[6]
Return nil
//-----------------------------------------------------------------------//
User Function IndigoReg(nTot)

nTotal:= nTot

if nTotal<100
	oMeter:nTotal:= nTotal
	nMeterDif:= 1
else
	oMeter:nTotal:= 25
	nMeterDif:= (oMeter:nTotal) / nTotal
endif

nAtual := 0

Return nil

//-----------------------------------------------------------------------//
User Function IndigoPrc(cMsg)

Default cMsg := ""
// implementaçao interna (c++) da IncProc ...
IntIncProc( cMsg )
return NIL
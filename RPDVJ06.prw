#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "aarray.ch"
#INCLUDE "json.ch"
#include "topconn.ch"
#include "tbiconn.ch"                                      

#DEFINE ENTER CHR(13)+CHR(10)
#DEFINE CUSTOMER_BLOCKED "3"
#DEFINE CUSTOMER_ENABLE  "4"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RPDVJ06  �Autor  �Fabio Simonetti     � Data �  01/05/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Integracao Indigo PDV - Processa o bloqueio de clientes    ���
�������������������������������������������������������������������������͹��
���Uso       � IndigoPDV                                               	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function RPDVJ06(aParam) 
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
Local nOpca          := 0
Local aSays          := {}
Local aButtons       := {}
Local aArea          := {}
Private lJob         := .F.
Default aParam       := {.F.}

//���������������������������������������������������������������������Ŀ
//� Determina a execucao via job                                        �
//�����������������������������������������������������������������������
lJob := aParam[1]

//���������������������������������������������������������������������Ŀ
//� Prepara o ambiente dependendo do modo de execucao                   �
//�����������������������������������������������������������������������
If lJob
     PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" FUNNAME FunName() TABLES "PA2"
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - IndigoPDV - bloqueio de clientes - (RPDVJ06) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))

     //���������������������������������������������������������������������������Ŀ
     //� Processa o envio do email                                                 �
     //�����������������������������������������������������������������������������
     PDVInterface()

     //���������������������������������������������������������������������������Ŀ
     //� Finaliza o ambiente                                                       �
     //�����������������������������������������������������������������������������
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - IndigoPDV - bloqueio de clientes  - (RPDVJ06) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))
     RESET ENVIRONMENT
Else
     //���������������������������������������������������������������������������Ŀ
     //� Monta tela principal                                                      �
     //�����������������������������������������������������������������������������
     AADD(aSays,OemToAnsi("Executa o envio de informa��es do cadastro de clientes do Protheus (RPDVJ06) ==> " ))
     AADD(aSays,OemToAnsi("Verifique o campo PDVSINC - Sincronismo para bloqueio clientes"   ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aButtons, { 1,.T.                              ,{|o| (PDVInterface(),o:oWnd:End())     }})
     AADD(aButtons, { 2,.T.                              ,{|o| o:oWnd:End()                     }})
     FormBatch( "IndigoPDV - IndigoPDV - Bloqueio de clientes", aSays, aButtons )
Endif
Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� RdMake   �CallEMails� Autor � Fabio Simonetti       � Data � 10/09/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function PDVInterface()
//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������
If lJob        
     procPDV()
Else
     U_IndProcess({|| procPDV() },"Processando...")
Endif
Return
/*������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Program   �PDVInterface �Author �Fabio Simonetti     � Date �  17/04/14   ���
����������������������������������������������������������������������������͹��
���Desc.     � Funcoes comuns e genericas de utilizacao dos portais          ���
����������������������������������������������������������������������������͹��
���Data      � Funcionalidade alterada ou incluida                           ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static function procPDV()
Local aHeadOut 	:= {}
Local cParPost 	:= ""
Local aHeadOut 	:= {}
Local aUpdFields:= {}
Local aQryFields:= {}
Local cHeadRet 	:= ""
Local sGetRet  	:= ""
Local cQuery	:= ""
Local nRegTot	:= 0
Local nReg		:= 0
Local cCodCli	:= ""

cSessionToken := u_GetToken()

If Empty(cSessionToken)
	If lJob
		ConOut("Problemas ao obter o SessionToken no fonte RPDVJ06")
		Return
	Else	
		Aviso("Aviso","N�o foi possivel obter o SessionToken para comunica��o com o Mobile.",{"Ok"},2)
		Return
	EndIf
EndIf

//���������������������������������Ŀ
//� Verifica conexao de internet	�
//�����������������������������������
If !u_verifyInternet(lJob)
	Return
Endif
		
//��������������������������������������������������������Ŀ
//� Abre de condicao de pagamento						   �
//����������������������������������������������������������
cQuery := "SELECT R_E_C_N_O_ PA2REC, D_E_L_E_T_ DEL, PA2_CNPJ " + ENTER
cQuery += "FROM "+RetSQLName("PA2")+" PA2 " + ENTER
cQuery += "WHERE PA2_FILIAL = '"+xFilial("PA2")+"' " + ENTER
cQuery += "AND PA2_MSEXP = '' " + ENTER

//�����������������������������Ŀ
//� Tabelas do sistema			�
//�������������������������������
dbSelectArea("PA2")
PA2->(dbSetOrder(1)) //PA2_FILIAL + PA2_CNPJ

dbSelectArea("SA1")
SA1->(dbSetOrder(1)) //PA2_FILIAL + PA2_CNPJ

//�����������������������������������������Ŀ
//� Execute the main query					�
//�������������������������������������������
If Select("QRY") > 0
	DbSelectArea("QRY")
	DbCloseArea()
EndIf
TcQuery cQuery New Alias "QRY"

While QRY->(!Eof())
	nRegTot++
	QRY->(dbSkip())
Enddo

If nRegTot == 0
	If lJob
		Conout("Sem registros aptos para integrar")
	Else
		MsgAlert("Sem registros aptos para integrar")	
	Endif
	Return
Endif
If !lJob
	U_IndigoReg(nRegTot)
Endif	

QRY->(dbGoTop())
While QRY->(!Eof())
	//��������������������������������������������������������Ŀ
	//� Verifica o Status									   �
	//����������������������������������������������������������
	nReg++
	If !lJob
		U_IndigoPrc("Processando: "+cValToChar(nReg)+"/"+cValTochar(nRegTot))
	Else
		Conout("Processando: "+cValToChar(nReg)+"/"+cValTochar(nRegTot))
    Endif
    
    If !Empty(QRY->DEL)
		//DELETE 
		aAdd(aQryFields,{"company_id",AllTrim(QRY->PA2_CNPJ),.T.})
		
		aaCustomers := u_queryNaInterface(cSessionToken,"SA1",aQryFields,lJob)
		For y := 1 To Len(aaCustomers:Get("results"))
			aQryFields := {}
			aUpdFields := {}
    
			cCodCli := aaCustomers:Get("results")[y]:get("protheus_id")
		    If SA1->(dbSeek(xFilial("SA1")+cCodCli))
		    	aAdd(aUpdFields,{"sync_status",CUSTOMER_BLOCKED})
		    	u_xAtualizarNaInterface(cSessionToken,"SA1", AllTrim(SA1->A1_PDVID), aUpdFields, lJob)
		    Endif
		Next y
		
		cSQL := "UPDATE "+RetSQLName("PA2")+" "
		cSQL += "SET PA2_MSEXP = '*' "
		cSQL += "WHERE PA2_PDVID = '"+Alltrim(QRY->PDVID)+"' "
		
		TcSqlExec(cSQL)
	Else
		PA2->(dbGoTo(QRY->PA2REC))
		
		aAdd(aQryFields,{"company_id",AllTrim(PA2->PA2_CNPJ),.T.})
			
		aaCustomers := u_queryNaInterface(cSessionToken,"SA1",aQryFields,lJob)
		For j := 1 To Len(aaCustomers:Get("results"))
			aQryFields := {}
			aUpdFields := {}
			
			cCodCli := aaCustomers:Get("results")[j]:get("protheus_id")
		    If SA1->(dbSeek(xFilial("SA1")+cCodCli))
		    	If PA2->PA2_MSBLQL == "1" //Bloqueado
		    		aAdd(aUpdFields,{"sync_status",CUSTOMER_BLOCKED})
		    	Else
		    		aAdd(aUpdFields,{"sync_status",CUSTOMER_ENABLE})
		    	Endif
		    	u_xAtualizarNaInterface(cSessionToken,"SA1", AllTrim(SA1->A1_PDVID), aUpdFields, lJob)
		    Endif
		    If j > Len(aaCustomers:Get("results"))
		    	Exit
		    Endif
		Next j

		PA2->(RecLock("PA2",.F.))
			PA2->PA2_MSEXP  := DtoS(dDataBase)+" - "+Time()
		PA2->(MsUnlock())
	Endif
	QRY->(dbSkip())
Enddo

If nRegTot > 0
	If !lJob
		MsgInfo("Processamento conclu�do, total de registros processados: "+cvalTochar(nRegTot))
	Endif
Endif

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PartStr   �Autor  �Fabio Simonetti     � Data �  04/30/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cria Grupo de Perguntas SXB                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function PartStr(cStr, nPart, cDelimiter)
Local nCurrent := 1
Local cLeft := cStr
Local nPos
Default cDelimiter := '.'

//Vai retirando de cLeft enquanto n�o chegar ao par�metro
While nCurrent < nPart
	nPos := At(cDelimiter, cLeft)
	If nPos == 0
		nPos := Len(cLeft) + 1
	Endif
	
	cLeft := Substr(cLeft, nPos + 1)
	nCurrent++
EndDo

nPos := At(cDelimiter, cLeft)
If nPos == 0
	nPos := Len(cLeft) + 1
Endif
cLeft := Left(cLeft, nPos - 1)

Return cLeft
#INCLUDE "Protheus.ch"
#INCLUDE "Fileio.ch"
#INCLUDE "aarray.ch"
#INCLUDE "json.ch"
#include "topconn.ch"
#include "tbiconn.ch"                                      

#DEFINE ENTER CHR(13)+CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RPDVJ04  �Autor  �Fabio Simonetti     � Data �  01/05/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Integracao Indigo PDV - Envio de produtos para a interface ���
�������������������������������������������������������������������������͹��
���Uso       � IndigoPDV                                               	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function RPDVJ04(aParam) 
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
     PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" FUNNAME FunName() TABLES "SB1"
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - IndigoPDV - Cadastro de produtos - (RPDVJ04) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))

     //���������������������������������������������������������������������������Ŀ
     //� Processa o envio do email                                                 �
     //�����������������������������������������������������������������������������
     PDVInterface()

     //���������������������������������������������������������������������������Ŀ
     //� Finaliza o ambiente                                                       �
     //�����������������������������������������������������������������������������
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - IndigoPDV - Cadastro de produtos  - (RPDVJ04) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))
     RESET ENVIRONMENT
Else
     //���������������������������������������������������������������������������Ŀ
     //� Monta tela principal                                                      �
     //�����������������������������������������������������������������������������
     AADD(aSays,OemToAnsi("Executa o envio de informa��es do cadastro do Protheus (RPDVJ04) ==> " ))
     AADD(aSays,OemToAnsi("Verifique o campo PDVSINC - Sincronismo para incluir novos produtos"   ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aButtons, { 1,.T.                              ,{|o| (PDVInterface(),o:oWnd:End())     }})
     AADD(aButtons, { 2,.T.                              ,{|o| o:oWnd:End()                     }})
     FormBatch( "IndigoPDV - IndigoPDV - Cadastro de produtos", aSays, aButtons )
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
Local cHeadRet 	:= ""
Local sGetRet  	:= ""
Local cQuery	:= ""
Local nRegTot	:= 0
Local nReg		:= 0
Local lUpdate 	   := .F.
Local cIDProduct   := ""
Local cDescription := ""
Local cMercosulID  := ""

//��������������������������������������������������������Ŀ
//� Abre de condicao de pagamento						   �
//����������������������������������������������������������
cQuery := "SELECT R_E_C_N_O_ SB1REC, D_E_L_E_T_ DEL, B1_PDVID PDVID " + ENTER
cQuery += "FROM "+RetSQLName("SB1")+" SB1 " + ENTER
cQuery += "WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + ENTER
cQuery += "AND B1_PDVSINC = 'S' " + ENTER
cQuery += "AND B1_MSEXP = '' " + ENTER

//���������������������������������Ŀ
//� Verifica conexao de internet	�
//�����������������������������������
If !u_verifyInternet(lJob)
	Return
Endif

cSessionToken := u_GetToken()

If Empty(cSessionToken)
	If lJob
		ConOut("Problemas ao obter o SessionToken no fonte RPDVJ04")
		Return
	Else	
		Aviso("Aviso","N�o foi possivel obter o SessionToken para comunica��o com o Mobile.",{"Ok"},2)
		Return
	EndIf
EndIf

//��������������������������������������������������������Ŀ
//� Abre de condicao de pagamento						   �
//����������������������������������������������������������
dbSelectArea("SB1")
SB1->(dbSetOrder(1)) //B1_FILIAL + B1_CODIGO

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
		u_excluiNaInterface(cSessionToken, "SB1",AllTrim(QRY->PDVID))
		
		cSQL := "UPDATE "+RetSQLName("SB1")+" "
		cSQL += "SET B1_MSEXP = 'X', B1_PDVLOG = '"+DtoS(dDataBase)+" - "+Time()+"' "
		cSQL += "WHERE B1_PDVID = '"+Alltrim(QRY->PDVID)+"' "
		
		TcSqlExec(cSQL)
	Else
		SB1->(dbGoTo(QRY->SB1REC))
		
		//indentifica como um post ou update
		lUpdate			:= .F.
		
		//Controle se foi realizado o update
		lUpdated		:= .F.
	    cIDProduct   	:= SB1->B1_COD
		cDescription 	:= SB1->B1_DESC
		cMercosulID  	:= SB1->B1_POSIPI

		If !Empty(SB1->B1_PDVLOG)
			//��������������������������������������������������������Ŀ
			//� Verifica os campos alterados						   �
			//����������������������������������������������������������
			aaProduct := u_obterNaInterface(cSessionToken, "SB1", AllTrim(SB1->B1_PDVID), lJob)
			//TODO - TESTAR
			If AllTrim(aaProduct:Get("product_id")) != AllTrim(cIDProduct)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaProduct:Get("description")) != AllTrim(cDescription)
				lUpdate := .T.
			Endif
			     
			If AllTrim(aaProduct:Get("mercosul_id")) != AllTrim(cMercosulID)
				lUpdate := .T.
			Endif
			
			//UPDATE   
			If lUpdate
				aUpdFields := {}
			 	aAdd(aUpdFields,{"product_id",cIDProduct})
			 	aAdd(aUpdFields,{"description",cDescription})
			 	aAdd(aUpdFields,{"mercosul_id",cMercosulID})
	
			 	u_xAtualizarNaInterface(cSessionToken, "SB1", AllTrim(SB1->B1_PDVID), aUpdFields, lJob)

				SB1->(RecLock("SB1",.F.))
					SB1->B1_MSEXP  := DtoS(dDataBase)+" - "+Time()
					SB1->B1_PDVLOG := DtoS(dDataBase)+" - "+Time()
				SB1->(MsUnlock())
			Else
				//����������������������������������������������������������Ŀ
				//� sem nenhum campo importante foi alterado apenas atualiza �
				//������������������������������������������������������������
				SB1->(RecLock("SB1",.F.))
					SB1->B1_MSEXP  := DtoS(dDataBase)+" - "+Time()
				SB1->(MsUnlock())
			Endif	
		Else
			//POST
			aaProduct := u_criaNaInterface(cSessionToken, "SB1",;
				'{"product_id":"'+cIDProduct+'","description":"'+cDescription+'","mercosul_id":"'+;
					cMercosulID+'"}',lJob)
					
			SB1->(RecLock("SB1",.F.))
				SB1->B1_MSEXP  := DtoS(dDataBase)+" - "+Time()
				SB1->B1_PDVLOG := DtoS(dDataBase)+" - "+Time()
				SB1->B1_PDVID  := aaProduct:Get("objectId")
				
			SB1->(MsUnlock())
		Endif
	Endif

	QRY->(dbSkip())
Enddo

If nRegTot > 0
	If !lJob
		MsgInfo("Processamento conclu�do, total de registros processados: "+cvalTochar(nRegTot))
	Endif
Endif

Return
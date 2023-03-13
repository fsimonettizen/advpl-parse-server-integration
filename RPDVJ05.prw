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
���Programa  � RPDVJ05  �Autor  �Fabio Simonetti     � Data �  01/05/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Integracao Indigo PDV - Envio de clientes para a interface ���
�������������������������������������������������������������������������͹��
���Uso       � IndigoPDV                                               	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function RPDVJ05(aParam) 
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
     PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" FUNNAME FunName() TABLES "SA1"
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - IndigoPDV - Cadastro de clientes - (RPDVJ05) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))

     //���������������������������������������������������������������������������Ŀ
     //� Processa o envio do email                                                 �
     //�����������������������������������������������������������������������������
     PDVInterface()

     //���������������������������������������������������������������������������Ŀ
     //� Finaliza o ambiente                                                       �
     //�����������������������������������������������������������������������������
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - IndigoPDV - Cadastro de clientes  - (RPDVJ05) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))
     RESET ENVIRONMENT
Else
     //���������������������������������������������������������������������������Ŀ
     //� Monta tela principal                                                      �
     //�����������������������������������������������������������������������������
     AADD(aSays,OemToAnsi("Executa o envio de informa��es do cadastro de clientes do Protheus (RPDVJ05) ==> " ))
     AADD(aSays,OemToAnsi("Verifique o campo PDVSINC - Sincronismo para incluir novos clientes"   ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aButtons, { 1,.T.                              ,{|o| (PDVInterface(),o:oWnd:End())     }})
     AADD(aButtons, { 2,.T.                              ,{|o| o:oWnd:End()                     }})
     FormBatch( "IndigoPDV - IndigoPDV - Cadastro de clientes", aSays, aButtons )
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
Local cIDCostumer  	:= ""
Local cCompanyName 	:= ""
Local cTradingName  := ""
Local cCompanyID  	:= ""
Local cCompStateID	:= ""
Local cAddress		:= ""
Local cCompAddNum	:= ""
Local cZIPCode		:= ""
Local cDistrict		:= ""
Local cCity			:= ""
Local cState		:= ""
Local cPhone		:= ""
Local cFaxPhone		:= ""
Local cEmail		:= ""
Local cContactName	:= ""
Local cRegionId		:= ""
Local cProtheusId	:= ""
Local cSegment1		:= ""
Local cSegment2		:= ""
Local cSegment3		:= ""
Local cSellerId		:= ""
Local cCustType 	:= ""
Local cStatus		:= ""
		
cSessionToken := u_GetToken()

If Empty(cSessionToken)
	If lJob
		ConOut("Problemas ao obter o SessionToken no fonte RPDVJ05")
		Return
	Else	
		Aviso("Aviso","N�o foi possivel obter o SessionToken para comunica��o com o Mobile.",{"Ok"},2)
		Return
	EndIf
EndIf

//��������������������������������������������������������Ŀ
//� Abre de condicao de pagamento						   �
//����������������������������������������������������������
cQuery := "SELECT R_E_C_N_O_ SA1REC, D_E_L_E_T_ DEL, A1_PDVID PDVID " + ENTER
cQuery += "FROM "+RetSQLName("SA1")+" SA1 " + ENTER
cQuery += "WHERE A1_FILIAL = '"+xFilial("SA1")+"' " + ENTER
cQuery += "AND A1_PDVSINC = 'S' " + ENTER
cQuery += "AND A1_MSEXP = '' " + ENTER

//���������������������������������Ŀ
//� Verifica conexao de internet	�
//�����������������������������������
If !u_verifyInternet(lJob)
	Return
Endif

//��������������������������������������������������������Ŀ
//� Abre de condicao de pagamento						   �
//����������������������������������������������������������
dbSelectArea("SX5")
SX5->(dbSetOrder(1)) //X5_FILIAL + X5_TABELA

//��������������������������������������������������������Ŀ
//� Abre de condicao de pagamento						   �
//����������������������������������������������������������
dbSelectArea("SA1")
SA1->(dbSetOrder(1)) //A1_FILIAL + A1_CODIGO

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

U_IndigoReg(nRegTot)

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
		If !Empty(QRY->PDVID)
			u_excluiNaInterface(cSessionToken,"SA1",AllTrim(QRY->PDVID))
			
			cSQL := "UPDATE "+RetSQLName("SA1")+" "
			cSQL += "SET A1_MSEXP = 'X', A1_PDVLOG = '"+DtoS(dDataBase)+" - "+Time()+"' "
			cSQL += "WHERE A1_PDVID = '"+Alltrim(QRY->PDVID)+"' "
			
			TcSqlExec(cSQL)
		Endif	
	Else
		SA1->(dbGoTo(QRY->SA1REC))
		
		//indentifica como um post ou update
		lUpdate			:= .F.
		
		//Controle se foi realizado o update
		lUpdated		:= .F.
	    cIDCostumer   	:= SA1->A1_COD
		cCompanyName 	:= SA1->A1_NOME
		cTradingName  	:= SA1->A1_NREDUZ
		cCompanyID  	:= SA1->A1_CGC
		cCompStateID	:= SA1->A1_INSCR
		cAddress		:= PartStr(SA1->A1_END, 1, ",")
		cCompAddNum		:= PartStr(SA1->A1_END, 2, ",")
		cZIPCode		:= SA1->A1_CEP
		cDistrict		:= SA1->A1_BAIRRO
		cCity			:= SA1->A1_MUN
		cState			:= SA1->A1_EST
		cPhone			:= SA1->(A1_DDD + A1_TEL)
		cFaxPhone		:= SA1->(A1_DDD + A1_FAX)
		cEmail			:= Alltrim(SA1->A1_EMAIL)
		cContactName	:= Alltrim(SA1->A1_CONTATO)
		cCustType		:= Alltrim(SA1->A1_TIPO)
		
		SX5->(dbSeek(xFilial("SX5")+"A2"+SA1->A1_REGIAO))
		cRegionId		:= Alltrim(SX5->X5_CHAVE)
		cProtheusId		:= Alltrim(SA1->(A1_COD + A1_LOJA))
		cSegment1		:= Alltrim(SA1->A1_XATIV1)
		cSegment2		:= Alltrim(SA1->A1_XATIV2)
		cSegment3		:= Alltrim(SA1->A1_XATIV3)
		cSellerId		:= Alltrim(SA1->A1_VEND)
		cStatus 		:= ""
		
		aArea := GetArea()
		If !Empty(SA1->A1_PDVLOG)
			//��������������������������������������������������������Ŀ
			//� Verifica os campos alterados						   �
			//����������������������������������������������������������
			aaCostumer := u_obterNaInterface(cSessionToken, "SA1", AllTrim(SA1->A1_PDVID), lJob)
			
			//TODO - TESTAR
			If AllTrim(aaCostumer:Get("company_name")) != AllTrim(cCompanyName)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("trading_name")) != AllTrim(cTradingName)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("company_id")) != AllTrim(cCompanyID) 
				lUpdate := .T.
			Endif

			If AllTrim(aaCostumer:Get("company_state_id")) != AllTrim(cCompStateID) 
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("company_address")) != AllTrim(cAddress)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("company_address_number")) != AllTrim(cCompAddNum)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("zipcode")) != AllTrim(cZIPCode)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("district")) != AllTrim(cDistrict)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("city")) != AllTrim(cCity)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("state")) != AllTrim(cState)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("phone_number")) != AllTrim(cPhone)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("fax_number")) != AllTrim(cFaxPhone)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("email")) != AllTrim(cEmail)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("contact_name")) != AllTrim(cContactName)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("region")) != AllTrim(cRegionId)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("protheus_id")) != AllTrim(cProtheusId)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("segment1")) != AllTrim(cSegment1)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("segment2")) != AllTrim(cSegment2)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("segment3")) != AllTrim(cSegment3)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaCostumer:Get("seller")) != AllTrim(cSellerId)
				lUpdate := .T.
			Endif
			     
			If AllTrim(aaCostumer:Get("customer_status")) != AllTrim(cStatus)
				lUpdate := .T.
			Endif
			    
			If AllTrim(aaCostumer:Get("type")) != AllTrim(cCustType)
				lUpdate := .T.
			Endif
			
			//UPDATE   
			If lUpdate
				aUpdFields := {}
			
				aAdd(aUpdFields,{"company_name",AllTrim(cCompanyName)})
				aAdd(aUpdFields,{"trading_name",AllTrim(cTradingName)})
				aAdd(aUpdFields,{"company_id",AllTrim(cCompanyID)})
				aAdd(aUpdFields,{"company_state_id",AllTrim(cCompStateID)})
				aAdd(aUpdFields,{"company_address",AllTrim(cAddress)})
				aAdd(aUpdFields,{"company_address_number",AllTrim(cCompAddNum)})
				aAdd(aUpdFields,{"zipcode",AllTrim(cZIPCode)})
				aAdd(aUpdFields,{"district",AllTrim(cDistrict)})
				aAdd(aUpdFields,{"city",AllTrim(cCity)})
				aAdd(aUpdFields,{"state",AllTrim(cState)})
				aAdd(aUpdFields,{"phone_number",AllTrim(cPhone)})
				aAdd(aUpdFields,{"fax_number",AllTrim(cFaxPhone)})
				aAdd(aUpdFields,{"email",AllTrim(cEmail)})
				aAdd(aUpdFields,{"contact_name",AllTrim(cContactName)})
				aAdd(aUpdFields,{"region",AllTrim(cRegionId)})
				aAdd(aUpdFields,{"protheus_id",AllTrim(cProtheusId)})
				aAdd(aUpdFields,{"segment1",AllTrim(cSegment1)})
				aAdd(aUpdFields,{"segment2",AllTrim(cSegment2)})
				aAdd(aUpdFields,{"segment3",AllTrim(cSegment3)})
				aAdd(aUpdFields,{"seller_id",AllTrim(cSellerId)})
				aAdd(aUpdFields,{"customer_status",AllTrim(cStatus)})
				aAdd(aUpdFields,{"type",cCustType})
				
			 	u_xAtualizarNaInterface(cSessionToken, "SA1", AllTrim(SA1->A1_PDVID), aUpdFields, lJob)

				SA1->(RecLock("SA1",.F.))
					SA1->A1_MSEXP  := DtoS(dDataBase)+" - "+Time()
					SA1->A1_PDVLOG := DtoS(dDataBase)+" - "+Time()
				SA1->(MsUnlock())
			Else
				//����������������������������������������������������������Ŀ
				//� sem nenhum campo importante foi alterado apenas atualiza �
				//������������������������������������������������������������
				SA1->(RecLock("SA1",.F.))
					SA1->A1_MSEXP  := DtoS(dDataBase)+" - "+Time()
				SA1->(MsUnlock())
			Endif	
		Else
			//POST
			aaCostumer := u_criaNaInterface(cSessionToken, "SA1",;           
				'{"company_name":"'+AllTrim(cCompanyName)+'"'+;
				',"trading_name":"'+AllTrim(cTradingName)+'"'+;
				',"company_id":"'+AllTrim(cCompanyID)+'"'+;
				',"company_state_id":"'+AllTrim(cCompanyID)+'"'+;
				',"company_address":"'+AllTrim(cAddress)+'"'+;
				',"company_address_number":"'+AllTrim(cCompAddNum)+'"'+;
				',"zipcode":"'+AllTrim(cZIPCode)+'"'+;
				',"district":"'+AllTrim(cDistrict)+'"'+;
				',"city":"'+AllTrim(cCity)+'"'+;
				',"state":"'+AllTrim(cState)+'"'+;
				',"phone_number":"'+AllTrim(cPhone)+'"'+;
				',"fax_number":"'+AllTrim(cFaxPhone)+'"'+;
				',"email":"'+AllTrim(cEmail)+'"'+;
				',"contact_name":"'+AllTrim(cContactName)+'"'+;
				',"region":"'+AllTrim(cRegionId)+'"'+;
				',"protheus_id":"'+AllTrim(cProtheusId)+'"'+;
				',"segment1":"'+AllTrim(cSegment1)+'"'+;
				',"segment2":"'+AllTrim(cSegment2)+'"'+;
				',"segment3":"'+AllTrim(cSegment3)+'"'+;
				',"customer_status":"'+AllTrim(cStatus)+'"'+;
				',"type":"'+AllTrim(cCustType)+'"'+;
				',"seller_id":"'+AllTrim(cSellerId)+'"}',;
				lJob)

			SA1->(RecLock("SA1",.F.))
				SA1->A1_MSEXP  := DtoS(dDataBase)+" - "+Time()
				SA1->A1_PDVLOG := DtoS(dDataBase)+" - "+Time()
				SA1->A1_PDVID  := aaCostumer:Get("objectId")
			SA1->(MsUnlock())
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
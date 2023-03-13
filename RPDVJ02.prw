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
���Programa  � RPDVJ02  �Autor  �Fabio Simonetti     � Data �  26/04/14   ���
�������������������������������������������������������������������������͹��
���Desc.     � Integracao Indigo PDV - Envio de segmentos				  ���
�������������������������������������������������������������������������͹��
���Uso       � IndigoPDV                                               	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function RPDVJ02(aParam) 
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
     PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" FUNNAME FunName() TABLES "SE4"
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - Condi��o de pagamento - (RPDVJ02) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))

     //���������������������������������������������������������������������������Ŀ
     //� Processa o envio do email                                                 �
     //�����������������������������������������������������������������������������
     PDVInterface()

     //���������������������������������������������������������������������������Ŀ
     //� Finaliza o ambiente                                                       �
     //�����������������������������������������������������������������������������
     ConOut(Repl("-",100))
     ConOut(Padc("Iniciando - Condi��o de pagamento - (RPDVJ02) ==> "+Dtoc(Date())+" "+Time(),100))
     ConOut(Repl("-",100))
     RESET ENVIRONMENT
Else
     //���������������������������������������������������������������������������Ŀ
     //� Monta tela principal                                                      �
     //�����������������������������������������������������������������������������
     AADD(aSays,OemToAnsi("Executa o envio de informa��es de condi��o de pagamento do Protheus (RPDVJ02) ==> " ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aSays,OemToAnsi(""                                                                      ))
     AADD(aButtons, { 1,.T.                              ,{|o| (PDVInterface(),o:oWnd:End())     }})
     AADD(aButtons, { 2,.T.                              ,{|o| o:oWnd:End()                     }})
     FormBatch( "IndigoPDV - Condi��o de pagamento", aSays, aButtons )
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
Local lUpdate 	 := .F.
Local cIDPayment   := ""
Local cCondPayment := ""
Local cDescPayment := ""

Local lErro     := .T.
Local lGravaOk	:= .F.

cSessionToken := u_GetToken()

If Empty(cSessionToken)
	If lJob
		ConOut("Problemas ao obter o SessionToken no fonte RPDVJ01")
	Else	
		Aviso("Aviso","N�o foi possivel obter o SessionToken para comunica��o com o Mobile.",{"Ok"},2)
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
cQuery := "SELECT R_E_C_N_O_ SE4REC, D_E_L_E_T_ DEL, E4_PDVID PDVID " + ENTER
cQuery += "FROM "+RetSQLName("SE4")+" SE4 " + ENTER
cQuery += "WHERE E4_FILIAL = '"+xFilial("SE4")+"' " + ENTER
cQuery += "AND E4_PDVSINC = 'S' " + ENTER
cQuery += "AND E4_MSEXP = '' " + ENTER

//��������������������������������������������������������Ŀ
//� Abre de condicao de pagamento						   �
//����������������������������������������������������������
dbSelectArea("SE4")
SE4->(dbSetOrder(1)) //E4_FILIAL + E4_CODIGO

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
		u_excluiNaInterface(cSessionToken, "SE4",AllTrim(QRY->PDVID))
		
		cSQL := "UPDATE "+RetSQLName("SE4")+" "
		cSQL += "SET E4_MSEXP = 'X', E4_PDVLOG = '"+DtoS(dDataBase)+" - "+Time()+"' "
		cSQL += "WHERE E4_PDVID = '"+Alltrim(QRY->PDVID)+"' "
		
		TcSqlExec(cSQL)
	Else
		SE4->(dbGoTo(QRY->SE4REC))
		
		//indentifica como um post ou update
		lUpdate			:= .F.
		
		//Controle se foi realizado o update
		lUpdated		:= .F.
	    cIDPayment   	:= SE4->E4_CODIGO
		cCondPayment 	:= SE4->E4_COND
		cDescPayment 	:= SE4->E4_DESCRI
		
		If !Empty(SE4->E4_PDVLOG)
			//��������������������������������������������������������Ŀ
			//� Verifica os campos alterados						   �
			//����������������������������������������������������������
			aaPaymentType := u_obterNaInterface(cSessionToken, "SE4", AllTrim(SE4->E4_PDVID), lJob)
			//TODO - TESTAR
			If AllTrim(aaPaymentType:Get("due_days_interval")) != AllTrim(cCondPayment)
				lUpdate := .T.
			Endif
			
			If AllTrim(aaPaymentType:Get("description")) != AllTrim(cDescPayment)
				lUpdate := .T.
			Endif
			
			//UPDATE   
			If lUpdate
				aUpdFields := {}
			 	aAdd(aUpdFields,{"due_days_interval",cCondPayment})
			 	aAdd(aUpdFields,{"description",cDescPayment})

			 	u_xAtualizarNaInterface(cSessionToken, "SE4", AllTrim(SE4->E4_PDVID), aUpdFields, lJob)

				SE4->(RecLock("SE4",.F.))
					SE4->E4_MSEXP  := DtoS(dDataBase)+" - "+Time()
					SE4->E4_PDVLOG := DtoS(dDataBase)+" - "+Time()
				SE4->(MsUnlock())
			Else
				//����������������������������������������������������������Ŀ
				//� sem nenhum campo importante foi alterado apenas atualiza �
				//������������������������������������������������������������
				SE4->(RecLock("SE4",.F.))
					SE4->E4_MSEXP  := DtoS(dDataBase)+" - "+Time()
				SE4->(MsUnlock())
			Endif	
		Else
			//POST
			aaPaymentType := u_criaNaInterface(cSessionToken, "SE4",;
				'{"payment_id":"'+cIDPayment+'","due_days_interval":"'+cCondPayment+'","description":"'+cDescPayment+'"}',;
				lJob)
					
			SE4->(RecLock("SE4",.F.))
				SE4->E4_MSEXP  := DtoS(dDataBase)+" - "+Time()
				SE4->E4_PDVLOG := DtoS(dDataBase)+" - "+Time()
				SE4->E4_PDVID  := aaPaymentType:Get("objectId")
				
			SE4->(MsUnlock())
		Endif
	Endif

	QRY->(dbSkip())
Enddo

If nRegTot > 0
	If !lJob
		MsgInfo("Processamento conclu�do")
	Endif
Endif

Return
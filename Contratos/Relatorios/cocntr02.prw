#include "totvs.ch"
#include "rptdef.ch"

#define MARGEM_ESQUERDA 20
#define MARGEM_DIREITA 10
#define MARGEM_SUPERIOR 20

/*/{Protheus.doc} COCNTR02
Impressão de layout de dados de medições de contrato
@type function
@author Rodrigo Godinho
@since 10/01/2024
/*/
User Function COCNTR02()
	Local oReport	:= ReportDef()
	oReport:PrintDialog()
Return

/*/{Protheus.doc} ReportDef
Definicao das configuracoes do relatorio
@type function
@author Rodrigo Godinho
@since 10/01/2024
@return object, Objeto TReport
/*/
Static Function ReportDef()
	Local oReport
	Local cReport	:= "COCNTR02"
	Local cTitulo	:= "Mapa de Medições de Contrato"
	Local cPergunta	:= "COCNTR02"

	Pergunte(cPergunta, .F.)
	
	oReport := TReport():New(cReport, cTitulo, cPergunta, {|oReport| ReportPrint(oReport)}, cTitulo)
	oReport:SetPortrait()
	oReport:HideHeader()
	oReport:HideParamPage()
	oReport:DisableOrientation()
	oReport:SetEdit(.F.)

	// oReport:SetTotalInLine(.F.)
	// Pergunte(oReport:uParam,.F.)
	
Return oReport

/*/{Protheus.doc} ReportPrint
Funcao de execucao da impressao
@type function
@author Rodrigo Godinho
@since 10/01/2024
@param oReport, object, Objeto TReport
/*/
Static Function ReportPrint(oReport)
	Local nMargemDir	:= oReport:PageWidth() - MARGEM_DIREITA
	Local nAlturaPagina	:= oReport:PageHeight(.F.)
	Local nPosLinBox	:= 0
	Local cAuxText		:= ""
	Local oFontSt01		:= TFont():New("Arial", , -14, , .T., , , , , , .T.)
	Local oFontSt02		:= TFont():New("Arial", , -12, , .T., , , , , , .F.)
	Local oFontSt03		:= TFont():New("Courier New", , -8, , .F., , , , , , .F.)
	Local oFontSt04		:= TFont():New("Courier New", , -10, , .T., , , , , , .F.)
	Local oFontSt05		:= TFont():New("Courier New", , -8, , .T., , , , , , .F.)
	Local oBrush 		:= TBrush():New(,GetRGB(220,220,220))
	Local nColCenter	:= 0
	Local nTextSize		:= 0
	Local aCoordsBox	:= {}
	Local nAlturaLinha	:= 120
	Local nAuxAltLinha	:= 0
	Local aFornecedores	:= {}
	Local nAltBoxFornec	:= 0
	Local nAltBoxObjeto	:= 0
	Local nAltBoxAnter	:= 0
	Local nAltBoxAlcada	:= 0
	Local nI			:= 0
	local nLinTexto		:= 0
	Local nQtdLinObj	:= 0
	// Local nTamChrFont	:= ""
	Local cTextoObjeto	:= ""
	Local aTextoObjeto	:= {}
	Local aItensMed		:= {}
	Local aTextoProd	:= {}
	Local aDocsPend		:= {}
	Local aMedAnter		:= {}
	Local aAlcMedicao	:= {}
	Local dVenctoMed	:= CToD("")
	Local lPosUltMed	:= .T.
	Local nTotVlrMed	:= 0
	Local nLimUltMed	:= Iif(MV_PAR02 > 0, MV_PAR02, 5)
	Local lFiltQtdZero	:= MV_PAR01 <> 1	
	Local cImgLogo		:= GetImage()
	Local nQtdLinMObs	:= 0
	Local cTxtObsMed	:= ""
	Local aTxtObsMed	:= {}
	Local nAltBDocPend	:= 0
	Local nTotalMedic	:= 0
	
	oReport:SetMeter(0)
	oReport:IncMeter()

	If oReport:nDevice == IMP_EXCEL
		FWAlertWarning("Este layout não pode ser gerado para o tipo 'Planilha'.", "Mapa de Medições")
		Return .F.
	EndIf

	nPosLinBox += MARGEM_SUPERIOR
	oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + 220 , nMargemDir ) 
	
	// Box dados empresa
	cAuxText := AllTrim(FWCodEmp()) + " - " + AllTrim(FWEmpName( FWCodEmp() )) + " - " + AllTrim(FWFilialName())
	nTextSize := CalcTxtSize(cAuxText, oFontSt01, oReport)
	nColCenter := CalcColCenter(cAuxText, oReport, oFontSt01)
	oReport:Say( nPosLinBox + 30 , nColCenter , cAuxText , oFontSt01, nTextSize )

	cAuxText := "MAPA DE MEDIÇÃO FÍSICO-FINANCEIRO E ACOMPANHAMENTO DO CONTRATO"
	nTextSize := CalcTxtSize(cAuxText, oFontSt02, oReport)
	nColCenter := CalcColCenter(cAuxText, oReport, oFontSt02)
	oReport:Say( nPosLinBox + 90 , nColCenter , cAuxText , oFontSt02, nTextSize )
	// Data da impressão
	cAuxText := cValToChar(Date())
	// nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 30 , nMargemDir - 152 , cAuxText , oFontSt03, nTextSize )
	// Hora da impressão
	cAuxText := Time()
	// nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 60 , nMargemDir - 122 , cAuxText , oFontSt03, nTextSize )

	If !Empty(cImgLogo)
		oReport:SayBitmap( nPosLinBox + 20 , MARGEM_ESQUERDA + 20 , cImgLogo , 165 , 160 )
	EndIf

	// Box dados do contrato
	nPosLinBox += 240
	nAltBoxFornec := 120
	aFornecedores := GetFornecedores(CN9->CN9_NUMERO, CN9->CN9_REVISA)
	If Len(aFornecedores) > 2
		nAltBoxFornec += (Len(aFornecedores) - 2)*30
	EndIf
	oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + nAltBoxFornec , nMargemDir )
	
	cAuxText := "Contrato: " + AllTrim(CN9->CN9_NUMERO)
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 20 , MARGEM_ESQUERDA + 20 , cAuxText , oFontSt03, nTextSize )

	For nI := 1 To Len(aFornecedores)
		cAuxText := "Fornecedor: " + AllTrim(aFornecedores[nI][3])
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 20 + (nI*30) , MARGEM_ESQUERDA + 20 , cAuxText , oFontSt03, nTextSize )
	Next

	cAuxText := "Valor Contrato: " + AllTrim(Transform(CN9->CN9_VLATU, PesqPict("CN9", "CN9_VLATU")))
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 20 , MARGEM_ESQUERDA + 1150 , cAuxText , oFontSt03, nTextSize )

	cAuxText := "Data de Inicio     : " + cValToChar(CN9->CN9_DTINIC)
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 20 , MARGEM_ESQUERDA + 1820 , cAuxText , oFontSt03, nTextSize ) 

	cAuxText := "Data de Conclusão  : " + cValToChar(CN9->CN9_DTFIM)
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 50 , MARGEM_ESQUERDA + 1820 , cAuxText , oFontSt03, nTextSize ) 

	cAuxText := "Prazo              : " + cValToChar(CN9->CN9_VIGE) + " " + AllTrim(GetCboxVal(CN9->CN9_UNVIGE, "CN9_UNVIGE"))
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 80 , MARGEM_ESQUERDA + 1820 , cAuxText , oFontSt03, nTextSize )

	
	// Box dados do objeto do contrato
	nPosLinBox += nAltBoxFornec + 20
	cTextoObjeto := MSMM(CN9->CN9_CODOBJ)
	While (At(CRLF+CRLF, cTextoObjeto)) > 0
		cTextoObjeto := Replace(cTextoObjeto, CRLF+CRLF, CRLF)
	EndDo
	// Obtenho o tamanho de um caractere desta fonte
	// nTamChrFont := CalcTxtSize("W", oFontSt03, oReport)
	aTextoObjeto := GetArrLines( cTextoObjeto, (nMargemDir - (MARGEM_ESQUERDA + 20)) / 15 )
	nAltBoxObjeto := 120
	If Len(aTextoObjeto) > 2
		nAltBoxObjeto += 40
	EndIf
	oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + nAltBoxObjeto , nMargemDir ) 

	cAuxText := "Objeto do Contrato: "
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 20 , MARGEM_ESQUERDA + 20 , cAuxText , oFontSt03, nTextSize )

	// Limita a impressão das 2 primeiras linhas do objeto
	nQtdLinObj := Min(2, Len(aTextoObjeto))
	For nI := 1 To nQtdLinObj
		cAuxText := AllTrim(aTextoObjeto[nI])
		// adiciona se tem mais linhas
		If nI == nQtdLinObj .And. nQtdLinObj < Len(aTextoObjeto)
			cAuxText += " ..."
		EndIf
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 20 + (nI*30), MARGEM_ESQUERDA + 20 , cAuxText , oFontSt03, nTextSize )
		// Imprime linha com mensagem que existem mais linhas
		If nI == nQtdLinObj .And. nQtdLinObj < Len(aTextoObjeto)
			cAuxText := " (Para consultar o texto completo do objeto acesse o contrato) "
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 20 + ((nI+1)*30), MARGEM_ESQUERDA + 20 , cAuxText , oFontSt03, nTextSize )
		EndIf
	Next
	nPosLinBox += nAltBoxObjeto + 20 
	
	// Imprime box de documentos pendentes para os contratos que controlam documentos
	If ControlaDoc(CN9->CN9_TPCTO)
		aDocsPend := GetDocsPend(CN9->CN9_NUMERO, dDataBase)
		If Len(aDocsPend) > 4
			nAltBDocPend := nAlturaLinha + (( Len(aDocsPend) - 4)*25)
		Else
			nAltBDocPend := nAlturaLinha
		EndIf	
		If (nPosLinBox + nAlturaLinha + nAltBDocPend) > nAlturaPagina
			oReport:EndPage()
			nPosLinBox := MARGEM_SUPERIOR + 100
		EndIf
		CreateBox(oReport, nPosLinBox, MARGEM_ESQUERDA, nPosLinBox + nAlturaLinha, nMargemDir, oBrush, , )
		
		cAuxText := "DOCUMENTOS PENDENTES"
		nTextSize := CalcTxtSize(cAuxText, oFontSt04, oReport)
		nColCenter := CalcColCenter(cAuxText, oReport, oFontSt04)
		oReport:Say( nPosLinBox + 16 , nColCenter , cAuxText , oFontSt04, nTextSize )	
		
		cAuxText := "Código"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 10, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Descrição"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 300, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Data Validade"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 2080, cAuxText , oFontSt03, nTextSize )		

		nPosLinBox += nAlturaLinha
		oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + nAltBDocPend , nMargemDir )
		For nI := 1 To Len(aDocsPend)
			// Codigo
			cAuxText := AllTrim(aDocsPend[nI][1])
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 10, cAuxText , oFontSt03, nTextSize )

			// Descricao
			cAuxText := AllTrim(aDocsPend[nI][2])
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 300, cAuxText , oFontSt03, nTextSize )

			// Data
			cAuxText := cValToChar(aDocsPend[nI][3])
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 2100, cAuxText , oFontSt03, nTextSize )

		Next
		nPosLinBox += nAltBDocPend + 20		
	EndIf

	lPosUltMed := PosicUltMed(CN9->CN9_NUMERO, CN9->CN9_REVISA)
	If lPosUltMed

		// Box cabeçalho da lista de itens da medição
		// oReport:FillRect({nPosLinBox, MARGEM_ESQUERDA, nPosLinBox + 150,nMargemDir},oBrush)
		// oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + 150 , nMargemDir )
		CreateBox(oReport, nPosLinBox, MARGEM_ESQUERDA, nPosLinBox + nAlturaLinha, nMargemDir, oBrush, , )

		cAuxText := "MEDIÇÃO ATUAL - " + AllTrim(GetMedStDescr(CND->CND_SITUAC))
		nTextSize := CalcTxtSize(cAuxText, oFontSt04, oReport)
		nColCenter := CalcColCenter(cAuxText, oReport, oFontSt04)
		oReport:Say( nPosLinBox + 8 , nColCenter , cAuxText , oFontSt04, nTextSize )

		cAuxText := "Numero Medição: " + AllTrim(CND->CND_NUMMED)
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , MARGEM_ESQUERDA + 20 , cAuxText , oFontSt03, nTextSize )

		cAuxText := "Data Medição: " + AllTrim(cValToChar(CND->CND_DTINIC))
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , MARGEM_ESQUERDA + 600 , cAuxText , oFontSt03, nTextSize )

		cAuxText := "Previsão Pagamento: "
		dVenctoMed := GetDtVencto(CND->CND_NUMMED, CND->CND_CONTRA, CND->CND_REVISA, CND->CND_CONDPG, Iif(Empty(CND->CND_DTFIM),dDataBase,CND->CND_DTFIM))
		If ValType(dVenctoMed) == "D" .And. !Empty(dVenctoMed)
			cAuxText += AllTrim(cValToChar(dVenctoMed))
		EndIf
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , MARGEM_ESQUERDA + 1200 , cAuxText , oFontSt03, nTextSize )

		cAuxText := "Periodo Medição: " + AllTrim(CND->CND_COMPET)
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , MARGEM_ESQUERDA + 1800 , cAuxText , oFontSt03, nTextSize )
		nPosLinBox += nAlturaLinha
		
		// Box com os títulos das colunas dos itens
		aCoordsBox := CriaBoxItem(oReport, nPosLinBox, nMargemDir, nAlturaLinha)

		cAuxText := "Planilha"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , aCoordsBox[1] + 10 , cAuxText , oFontSt03, nTextSize )

		cAuxText := "Item"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , aCoordsBox[2] + 10 , cAuxText , oFontSt03, nTextSize )

		cAuxText := "Cod. Produto"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , aCoordsBox[3] + 10 , cAuxText , oFontSt03, nTextSize )

		cAuxText := "Desc. Produto"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , aCoordsBox[4] + 10 , cAuxText , oFontSt03, nTextSize )

		cAuxText := "U.M."
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , aCoordsBox[5] + 10 , cAuxText , oFontSt03, nTextSize )

		cAuxText := "Quantidade"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , aCoordsBox[6] + 10 , cAuxText , oFontSt03, nTextSize )

		cAuxText := "Valor Unit."
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , aCoordsBox[7] + 10 , cAuxText , oFontSt03, nTextSize )

		cAuxText := "Valor Total"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75 , aCoordsBox[8] + 10 , cAuxText , oFontSt03, nTextSize )

		// Boxes dos itens, observações e resumo ( deduções, descontos e resumo)
		aItensMed := GetItensMed(CND->CND_NUMMED, CND->CND_CONTRA, CND->CND_REVISA, lFiltQtdZero)
		If Len(aItensMed) > 0
			oReport:SetMeter(Len(aItensMed))
			nPosLinBox += nAlturaLinha

			For nI := 1 To Len(aItensMed)
				oReport:IncMeter()
				// Grid do item
				aTextoProd := GetArrLines(AllTrim(aItensMed[nI][4]), 54)
				If Len(aTextoProd) > 4
					nAuxAltLinha := nAlturaLinha + (25 * (aTextoProd-4))
				Else
					nAuxAltLinha := nAlturaLinha
				EndIf
				If (nPosLinBox + nAuxAltLinha) > nAlturaPagina
					oReport:EndPage()
					nPosLinBox := MARGEM_SUPERIOR + 100
				EndIf

				aSize(aCoordsBox, 0)
				aCoordsBox := CriaBoxItem(oReport, nPosLinBox, nMargemDir, nAuxAltLinha)
				// Dados do item
				
				cAuxText := AllTrim(aItensMed[nI][1])
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10 , aCoordsBox[1] + 10 , cAuxText , oFontSt03, nTextSize )
				
				cAuxText := AllTrim(aItensMed[nI][2])
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10 , aCoordsBox[2] + 10 , cAuxText , oFontSt03, nTextSize )

				cAuxText := AllTrim(aItensMed[nI][3])
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10 , aCoordsBox[3] + 10 , cAuxText , oFontSt03, nTextSize )

				For nLinTexto := 1 To Len(aTextoProd)
					cAuxText := AllTrim(aTextoProd[nLinTexto])
					nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
					oReport:Say( nPosLinBox + 10 + ((nLinTexto - 1)*25) , aCoordsBox[4] + 10 , cAuxText , oFontSt03, nTextSize )
				Next

				cAuxText := AllTrim(aItensMed[nI][5])
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10 , aCoordsBox[5] + 10 , cAuxText , oFontSt03, nTextSize )

				cAuxText := Transform(aItensMed[nI][6], PesqPict("CNE", "CNE_QUANT"))
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10 , aCoordsBox[6] + 10 , cAuxText , oFontSt03, nTextSize )

				cAuxText := Transform(aItensMed[nI][7], PesqPict("CNE", "CNE_VLUNIT"))
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10 , aCoordsBox[7] + 10 , cAuxText , oFontSt03, nTextSize )

				nTotVlrMed += aItensMed[nI][8]
				cAuxText := Transform(aItensMed[nI][8], PesqPict("CNE", "CNE_VLTOT"))
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10 , aCoordsBox[8] + 10 , cAuxText , oFontSt03, nTextSize )
				
				// Incremento a altura da linha baseado na altura da linha atual
				nPosLinBox += nAuxAltLinha		
			Next
			aSize(aCoordsBox, 0)

			If (nPosLinBox + nAlturaLinha) > nAlturaPagina
				oReport:EndPage()
				nPosLinBox := MARGEM_SUPERIOR + 100
			EndIf

			// Imprime total
			oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + nAlturaLinha , nMargemDir ) 
			cAuxText := "Valor Total"
			nTextSize := CalcTxtSize(cAuxText, oFontSt04, oReport)
			oReport:Say( nPosLinBox + 60 , MARGEM_ESQUERDA + 10 , cAuxText , oFontSt04, nTextSize )

			cAuxText := Transform(nTotVlrMed, PesqPict("CNE", "CNE_VLTOT"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt04, oReport)
			oReport:Say( nPosLinBox + 60 , nMargemDir -360 , cAuxText , oFontSt04, nTextSize )
			nPosLinBox += nAlturaLinha


			If (nPosLinBox + nAlturaLinha) > nAlturaPagina
				oReport:EndPage()
				nPosLinBox := MARGEM_SUPERIOR + 100
			EndIf

			oReport:SetMeter(0)
			oReport:IncMeter()

			// Box dados da observação da medição
			cTxtObsMed := AllTrim(CND->CND_OBS)
			While (At(CRLF+CRLF, cTxtObsMed)) > 0
				cTxtObsMed := Replace(cTxtObsMed, CRLF+CRLF, CRLF)
			EndDo
			aTxtObsMed := GetArrLines( cTxtObsMed, (nMargemDir - (MARGEM_ESQUERDA + 20)) / 15 )
			nAltBObsMed := 120
			If Len(aTxtObsMed) > 2
				nAltBObsMed += 40
			EndIf
			oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + nAltBObsMed , nMargemDir ) 

			cAuxText := "Observações da medição:"
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 20 , MARGEM_ESQUERDA + 20 , cAuxText , oFontSt03, nTextSize )

			// Limita a impressão das 2 primeiras linhas da observacao
			nQtdLinMObs := Min(2, Len(aTxtObsMed))
			For nI := 1 To nQtdLinMObs
				cAuxText := AllTrim(aTxtObsMed[nI])
				// adiciona se tem mais linhas
				If nI == nQtdLinMObs .And. nQtdLinMObs < Len(aTxtObsMed)
					cAuxText += " ..."
				EndIf
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 20 + (nI*30), MARGEM_ESQUERDA + 20 , cAuxText , oFontSt03, nTextSize )
				// Imprime linha com mensagem que existem mais linhas
				If nI == nQtdLinMObs .And. nQtdLinMObs < Len(aTxtObsMed)
					cAuxText := " (Para consultar o texto completo do objeto acesse o contrato) "
					nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
					oReport:Say( nPosLinBox + 20 + ((nI+1)*30), MARGEM_ESQUERDA + 20 , cAuxText , oFontSt03, nTextSize )
				EndIf
			Next
			nPosLinBox += nAltBObsMed

			// oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + nAlturaLinha , nMargemDir ) 
			// cAuxText := "Observações da medição:"
			// nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			// oReport:Say( nPosLinBox + 10 , MARGEM_ESQUERDA + 10 , cAuxText , oFontSt03, nTextSize )
			// nPosLinBox += nAlturaLinha


			// Imprime boxes de retenções, descontos e resumo
			If (nPosLinBox + 160) > nAlturaPagina
				oReport:EndPage()
				nPosLinBox := MARGEM_SUPERIOR + 100
			EndIf

			aCoordsBox := CriaBoxResumo(oReport, nPosLinBox, nMargemDir, 60)
			cAuxText := "RETENÇÕES"
			nTextSize := CalcTxtSize(cAuxText, oFontSt04, oReport)
			oReport:Say( nPosLinBox + 12 , Int(aCoordsBox[2]/2 - (nTextSize/2))  , cAuxText , oFontSt04, nTextSize )

			cAuxText := "DESCONTOS"
			nTextSize := CalcTxtSize(cAuxText, oFontSt04, oReport)
			oReport:Say( nPosLinBox + 12 , aCoordsBox[2] + ((aCoordsBox[3] - aCoordsBox[2])/2) - (nTextSize/2) , cAuxText , oFontSt04, nTextSize )

			cAuxText := "RESUMO"
			nTextSize := CalcTxtSize(cAuxText, oFontSt04, oReport)
			oReport:Say( nPosLinBox + 12 ,aCoordsBox[3] + ((nMargemDir - aCoordsBox[3])/2) - (nTextSize/2) , cAuxText , oFontSt04, nTextSize )	
			nPosLinBox += 60

			aCoordsBox := CriaBoxResumo(oReport, nPosLinBox, nMargemDir, nAlturaLinha + 100)
			// Dados de retenções
			If !Empty(CND->CND_DTFIM)

				cAuxText := "Descrição"
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10,  aCoordsBox[1] + (160-(nTextSize/2)), cAuxText , oFontSt03, nTextSize )
				oReport:Line( nPosLinBox + 42,  aCoordsBox[1] + 10, nPosLinBox + 42, aCoordsBox[1] + 340 )	

				cAuxText := "Data"
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10,  aCoordsBox[1] + (430-(nTextSize/2)), cAuxText , oFontSt03, nTextSize )
				oReport:Line( nPosLinBox + 42,  aCoordsBox[1] + 360, nPosLinBox + 42, aCoordsBox[1] + 500 )
				
				cAuxText := "Valor"
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10,  aCoordsBox[1] + (620-(nTextSize/2)), cAuxText , oFontSt03, nTextSize )		
				oReport:Line( nPosLinBox + 42,  aCoordsBox[1] + 520, nPosLinBox + 42, aCoordsBox[1] + 760 )

				cAuxText := "CAUÇÃO POR MEDIÇÃO"
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 50 ,  aCoordsBox[1] + 10, cAuxText , oFontSt03, nTextSize )

				cAuxText := AllTrim(cValToChar(CND->CND_DTFIM))
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 50 ,  aCoordsBox[1] + 360, cAuxText , oFontSt03, nTextSize )

				cAuxText := Transform(CND->CND_RETCAC, PesqPict("CND", "CND_RETCAC"))
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 50 ,  aCoordsBox[1] + 520, cAuxText , oFontSt03, nTextSize )				
			EndIf

			// Dados de descontos
			If CND->CND_DESCME <> 0
				cAuxText := "Valor de desconto: " + AllTrim(Transform(CND->CND_DESCME, PesqPict("CND", "CND_DESCME")))
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10 ,  aCoordsBox[2] + 10, cAuxText , oFontSt03, nTextSize )
			Else
				cAuxText := "Não há descontos nesta medição."
				nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
				oReport:Say( nPosLinBox + 10 ,  aCoordsBox[2] + 10, cAuxText , oFontSt03, nTextSize )
			EndIf

			// Dados de resumo	
			cAuxText := "Valor dos Itens(+)  :           " + Transform(CND->CND_VLLIQD, PesqPict("CND", "CND_VLTOT"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 ,  aCoordsBox[3] + 10, cAuxText , oFontSt03, nTextSize )

			cAuxText := "Retenções(-)        :           " + Transform(CND->CND_RETCAC, PesqPict("CND", "CND_VLTOT"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 35 ,  aCoordsBox[3] + 10, cAuxText , oFontSt03, nTextSize )

			cAuxText := "Descontos(-)        :           " + Transform(CND->CND_DESCME, PesqPict("CND", "CND_VLTOT"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 60 ,  aCoordsBox[3] + 10, cAuxText , oFontSt03, nTextSize )

			cAuxText := "Multas(-)           :           " + Transform(CND->CND_VLMULT, PesqPict("CND", "CND_VLTOT"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 85 ,  aCoordsBox[3] + 10, cAuxText , oFontSt03, nTextSize )
			
			cAuxText := "Bonificações(+)     :           " + Transform(CND->CND_VLBONI, PesqPict("CND", "CND_VLTOT"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 110 ,  aCoordsBox[3] + 10, cAuxText , oFontSt03, nTextSize )
			oReport:Line( nPosLinBox + 142,  aCoordsBox[3] + 300, nPosLinBox + 142,  aCoordsBox[3] + 770 )

			cAuxText := "Total Liquido       :           " + Transform(CND->CND_VLTOT, PesqPict("CND", "CND_VLTOT"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt05, oReport)
			oReport:Say( nPosLinBox + 148 ,  aCoordsBox[3] + 10, cAuxText , oFontSt05, nTextSize )					
			nPosLinBox += nAlturaLinha + 120
		Else
			nPosLinBox += nAlturaLinha + 20
		EndIf

		// Box Medições anteriores
		aMedAnter := GetMedAnteriores(CND->CND_NUMMED, CND->CND_CONTRA, CND->CND_REVISA, nLimUltMed)
		If Len(aMedAnter) > 4
			nAltBoxAnter := nAlturaLinha + (( Len(aMedAnter) - 4)*25)
		Else
			nAltBoxAnter := nAlturaLinha
		EndIf

		If (nPosLinBox + (nAlturaLinha + nAltBoxAnter) + 20) > nAlturaPagina
			oReport:EndPage()
			nPosLinBox := MARGEM_SUPERIOR + 100
		EndIf
		// Imprime o cabeçalho das medições anteriores
		CreateBox(oReport, nPosLinBox, MARGEM_ESQUERDA, nPosLinBox + nAlturaLinha, nMargemDir, oBrush, , )
		cAuxText := "MEDIÇÕES ANTERIORES - " + AllTrim(cValToChar(nLimUltMed)) + " últimas medições"
		nTextSize := CalcTxtSize(cAuxText, oFontSt04, oReport)
		nColCenter := CalcColCenter(cAuxText, oReport, oFontSt04)
		oReport:Say( nPosLinBox + 16 , nColCenter , cAuxText , oFontSt04, nTextSize )

		cAuxText := "Medição"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 10, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Data Med."
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 150, cAuxText , oFontSt03, nTextSize )	

		cAuxText := "Prev. Pgto"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 340, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Periodo"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 520, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Vlr. Medição"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 700, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Ret. Contrat."
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 960, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Vlr. Descontos"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 1220, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Vlr. Multa"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 1560, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Vlr. Bonif."
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 1840, cAuxText , oFontSt03, nTextSize )		

		cAuxText := "Vlr. Liquido"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 2160, cAuxText , oFontSt03, nTextSize )	

		nPosLinBox += nAlturaLinha

		// Imprime os ítens das medições anteriores
		oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + nAltBoxAnter , nMargemDir )
		For nI := 1 To Len(aMedAnter)
			// Medição
			cAuxText := cValToChar(aMedAnter[nI][1])
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 10, cAuxText , oFontSt03, nTextSize )

			// Data Medição
			cAuxText := cValToChar(aMedAnter[nI][2])
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 140, cAuxText , oFontSt03, nTextSize )

			// Previsão Pgto
			cAuxText := cValToChar(aMedAnter[nI][3])
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 340, cAuxText , oFontSt03, nTextSize )

			// Periodo
			cAuxText := cValToChar(aMedAnter[nI][4])
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 520, cAuxText , oFontSt03, nTextSize )

			// Vlr. Medição
			cAuxText := Transform(aMedAnter[nI][5], PesqPict("CND", "CND_VLLIQD"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 610, cAuxText , oFontSt03, nTextSize )

			// Ret. Contrat.
			cAuxText := Transform(aMedAnter[nI][6], PesqPict("CND", "CND_RETCAC"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 930, cAuxText , oFontSt03, nTextSize )

			// Vlr. Descontos
			cAuxText := Transform(aMedAnter[nI][7], PesqPict("CND", "CND_DESCME"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 1160, cAuxText , oFontSt03, nTextSize )

			// Vlr. Multa
			cAuxText := Transform(aMedAnter[nI][8], PesqPict("CND", "CND_VLMULT"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 1460, cAuxText , oFontSt03, nTextSize )

			// Vlr. Bonificacao
			cAuxText := Transform(aMedAnter[nI][9], PesqPict("CND", "CND_VLBONI"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 1760, cAuxText , oFontSt03, nTextSize )

			// Vlr. Liquido
			cAuxText := Transform(aMedAnter[nI][10], PesqPict("CND", "CND_VLTOT"))
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 2060, cAuxText , oFontSt03, nTextSize )

		Next
		nPosLinBox += nAltBoxAnter + 20

		// Historico de ocorrências da medição atual
		aAlcMedicao := GetAlcMed(CND->CND_NUMMED)
		If Len(aAlcMedicao) > 4
			nAltBoxAlcada := nAlturaLinha + (( Len(aAlcMedicao) - 4)*25)
		Else
			nAltBoxAlcada := nAlturaLinha
		EndIf	
		If (nPosLinBox + nAlturaLinha + nAltBoxAlcada) > nAlturaPagina
			oReport:EndPage()
			nPosLinBox := MARGEM_SUPERIOR + 100
		EndIf
		CreateBox(oReport, nPosLinBox, MARGEM_ESQUERDA, nPosLinBox + nAlturaLinha, nMargemDir, oBrush, , )
		
		cAuxText := "HISTÓRICO DE OCORRÊNCIAS DA MEDIÇÃO ATUAL"
		nTextSize := CalcTxtSize(cAuxText, oFontSt04, oReport)
		nColCenter := CalcColCenter(cAuxText, oReport, oFontSt04)
		oReport:Say( nPosLinBox + 16 , nColCenter , cAuxText , oFontSt04, nTextSize )	
		
		cAuxText := "Usuário"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 10, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Nível"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 900, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Data"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 1140, cAuxText , oFontSt03, nTextSize )

		cAuxText := "Descrição Status"
		nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
		oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 1300, cAuxText , oFontSt03, nTextSize )		
		nPosLinBox += nAlturaLinha

		oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + nAltBoxAlcada , nMargemDir )
		For nI := 1 To Len(aAlcMedicao)
			// Usuario
			cAuxText := AllTrim(aAlcMedicao[nI][1])
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 10, cAuxText , oFontSt03, nTextSize )

			// Nivel
			cAuxText := AllTrim(aAlcMedicao[nI][2])
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 900, cAuxText , oFontSt03, nTextSize )

			// Data
			cAuxText := cValToChar(aAlcMedicao[nI][3])
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 1100, cAuxText , oFontSt03, nTextSize )

			// Descricao do status
			cAuxText := AllTrim(aAlcMedicao[nI][4])
			nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
			oReport:Say( nPosLinBox + 10 + ((nI-1)*25) ,  MARGEM_ESQUERDA + 1300, cAuxText , oFontSt03, nTextSize )

		Next
		nPosLinBox += nAltBoxAlcada	+ 20
		
	Else
		// Box cabeçalho da lista de itens da medição
		nPosLinBox += nAltBoxObjeto + 20 
		oBrush := TBrush():New(,GetRGB(220,220,220))
		// oReport:FillRect({nPosLinBox, MARGEM_ESQUERDA, nPosLinBox + 150,nMargemDir},oBrush)
		// oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + 150 , nMargemDir )
		CreateBox(oReport, nPosLinBox, MARGEM_ESQUERDA, nPosLinBox + nAlturaLinha, nMargemDir, oBrush, , )

		cAuxText := "Não há medições para este contrato/revisão ."
		nTextSize := CalcTxtSize(cAuxText, oFontSt04, oReport)
		nColCenter := CalcColCenter(cAuxText, oReport, oFontSt04)
		oReport:Say( nPosLinBox + 20 , nColCenter , cAuxText , oFontSt04, nTextSize )

		nPosLinBox += nAlturaLinha + 20
	EndIf


	// Box dos totais e saldos do contrato
	If (nPosLinBox + (nAlturaLinha*2) ) > nAlturaPagina
		oReport:EndPage()
		nPosLinBox := MARGEM_SUPERIOR + 100
	EndIf
	CreateBox(oReport, nPosLinBox, MARGEM_ESQUERDA, nPosLinBox + nAlturaLinha, nMargemDir, oBrush, , )
	
	cAuxText := "TOTAIS DO CONTRATO"
	nTextSize := CalcTxtSize(cAuxText, oFontSt04, oReport)
	nColCenter := CalcColCenter(cAuxText, oReport, oFontSt04)
	oReport:Say( nPosLinBox + 16 , nColCenter , cAuxText , oFontSt04, nTextSize )	
	
	cAuxText := "Valor Total Contrato"
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 20, cAuxText , oFontSt03, nTextSize )

	cAuxText := "Total das Medições"
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 1000, cAuxText , oFontSt03, nTextSize )

	cAuxText := "Saldo Contrato"
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 75,  MARGEM_ESQUERDA + 2100, cAuxText , oFontSt03, nTextSize )
	nPosLinBox += nAlturaLinha

	oReport:Box( nPosLinBox , MARGEM_ESQUERDA , nPosLinBox + nAlturaLinha , nMargemDir )
	// Total contrato
	cAuxText := Transform(CN9->CN9_VLATU, PesqPict("CN9", "CN9_VLATU"))
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 10 ,  MARGEM_ESQUERDA + 36, cAuxText , oFontSt03, nTextSize )

	// Soma dos valores de medições
	nTotalMedic := SomaMedicoes(CN9->CN9_NUMERO, CN9->CN9_REVISA)
	cAuxText := Transform(nTotalMedic, PesqPict("CN9", "CN9_VLATU"))
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 10 ,  MARGEM_ESQUERDA + 996, cAuxText , oFontSt03, nTextSize )

	// Saldo do contrato
	cAuxText := Transform(CN9->CN9_SALDO, PesqPict("CN9", "CN9_SALDO"))
	nTextSize := CalcTxtSize(cAuxText, oFontSt03, oReport)
	oReport:Say( nPosLinBox + 10 ,  MARGEM_ESQUERDA + 2018, cAuxText , oFontSt03, nTextSize )

	nPosLinBox += nAlturaLinha	+ 20

Return

/*/{Protheus.doc} CalcColCenter
Calcula a coluna para o texto centralizado
@type function
@author Rodrigo Godinho
@since 10/01/2024
@param cText, character, Texto
@param oReport, object, TReport
@param oFont, object, Fonte
@return numeric, Coluna para o texto centralizado
/*/
Static Function CalcColCenter(cText, oReport, oFont)
	Local nRet	:= 0
	nRet := oReport:PageWidth()/2 - CalcTxtSize(cText, oFont, oReport)/2 + oReport:LeftMargin()/2
Return nRet

/*/{Protheus.doc} CalcTxtSize
Retorna o tamanho do texto
@type function
@author Rodrigo Godinho
@since 10/01/2024
@param cText, character, Texto
@param oFont, object, Fonte
@param oReport, object, Objeto TReport
@return numeric, Tamanho do texto
/*/
Static Function CalcTxtSize(cText, oFont, oReport)
	Local nRet	:= 0
	nRet := oReport:Char2Pix(cText, oFont:Name, Abs(oFont:nHeight)-4, oFont:Italic)
Return nRet

/*/{Protheus.doc} GetPageWith
Retorna o tamanho da pagina
@type function
@author Rodrigo Godinho
@since 12/01/2024
@param oReport, object, Objeto da classe TReport
@return numeric, Tamanho da pagina
/*/
Static Function GetPageWith(oReport)
	Local nRet	:= 0
	Local oBorder
	nRet := oReport:PageWidth()
	oBorder := oReport:Border("RIGHT")
	If ValType(oBorder) == "O"
		nRet += oBorder:Weight()
	EndIf
Return nRet

/*/{Protheus.doc} GetRGB
Retorna o valor da Cor para o Protheus de acordo com o RGB
@type function
@author Rodrigo Godinho
@since 11/01/2024
@param nRed, numeric, Red
@param nGreen, numeric, Green
@param nBlue, numeric, Blue
@return numeric, Valor da cor para o Protheus
/*/
Static Function GetRGB(nRed, nGreen, nBlue)
	Default nRed	:= 0
	Default nGreen	:= 0
	Default nBlue	:= 0
Return nRed + nGreen*(2^8) + nBlue*(2^16)

/*/{Protheus.doc} CriaBoxItem
Cria caixa de itens
@type function
@author Rodrigo Godinho
@since 11/01/2024
@param oReport, object, TReport
@param nPosLinBox, numeric, Linha posicao inicial
@param nMargemDir, numeric, Coluna final
/*/
Static Function CriaBoxItem(oReport, nPosLinBox, nMargemDir, nHeight)
	Local aRet			:= {}
	Local nPosCol1		:= MARGEM_ESQUERDA
	Local nPosCol2		:= nPosCol1 + 132
	Local nPosCol3		:= nPosCol2 + 72
	Local nPosCol4		:= nPosCol3 + 360
	Local nPosCol5		:= nMargemDir - ((320*3) + 64 )
	Local nPosCol6		:= nMargemDir - (320*3)
	Local nPosCol7		:= nMargemDir - (320*2)
	Local nPosCol8		:= nMargemDir - 320
	
	Default nHeight	:= 120

	oReport:Box( nPosLinBox , nPosCol1 , nPosLinBox + nHeight , nPosCol2 )
	oReport:Box( nPosLinBox , nPosCol2 , nPosLinBox + nHeight , nPosCol3 )
	oReport:Box( nPosLinBox , nPosCol3 , nPosLinBox + nHeight , nPosCol4 )
	oReport:Box( nPosLinBox , nPosCol4 , nPosLinBox + nHeight , nPosCol5 )
	oReport:Box( nPosLinBox , nPosCol5 , nPosLinBox + nHeight , nPosCol6 )
	oReport:Box( nPosLinBox , nPosCol6 , nPosLinBox + nHeight , nPosCol7 )
	oReport:Box( nPosLinBox , nPosCol7 , nPosLinBox + nHeight , nPosCol8 )
	oReport:Box( nPosLinBox , nPosCol8 , nPosLinBox + nHeight , nMargemDir )

	aAdd(aRet, nPosCol1)
	aAdd(aRet, nPosCol2)
	aAdd(aRet, nPosCol3)
	aAdd(aRet, nPosCol4)
	aAdd(aRet, nPosCol5)
	aAdd(aRet, nPosCol6)
	aAdd(aRet, nPosCol7)
	aAdd(aRet, nPosCol8)

Return aRet

/*/{Protheus.doc} CriaBoxResumo
Cria box de resumo
@type function
@author Rodrigo Godinho
@since 15/01/2024
@param oReport, object, Objeto da classe treport
@param nPosLinBox, numeric, linha inicial
@param nMargemDir, numeric, margem direita
@param nHeight, numeric, altura
@return array, Array de coordenadas das colunas do box
/*/
Static Function CriaBoxResumo(oReport, nPosLinBox, nMargemDir, nHeight)
	Local aRet			:= {}
	Local nPosCol1		:= MARGEM_ESQUERDA
	Local nPosCol2		:= Int((nMargemDir - MARGEM_ESQUERDA)/3)
	Local nPosCol3		:= nPosCol2 * 2
	
	Default nHeight	:= 60

	oReport:Box( nPosLinBox , nPosCol1 , nPosLinBox + nHeight , nPosCol2 )
	oReport:Box( nPosLinBox , nPosCol2 , nPosLinBox + nHeight , nPosCol3 )
	oReport:Box( nPosLinBox , nPosCol3 , nPosLinBox + nHeight , nMargemDir )


	aAdd(aRet, nPosCol1)
	aAdd(aRet, nPosCol2)
	aAdd(aRet, nPosCol3)

Return aRet

/*/{Protheus.doc} CreateBox
Cria uma caixa
@type function
@author Rodrigo Godinho
@since 12/01/2024
@param oReport, object, Objeto TReport
@param nRow, numeric, Linha inicial
@param nCol, numeric, Coluna inicial
@param nHeight, numeric, Altura
@param nWidth, numeric, Largura
@param oBrushContent, object, Objeto TBrush do conteudo
@param oBrushBorder, object, Objeto TBrush da borda
@param nSizeBorder, numeric, Tamanho da borda
/*/
Static Function CreateBox(oReport, nRow , nCol , nHeight , nWidth, oBrushContent, oBrushBorder, nSizeBorder)
	Default oBrushContent	:= TBrush():New(,GetRGB(255,255,255))
	Default oBrushBorder	:= TBrush():New(,GetRGB(0,0,0))
	Default nSizeBorder		:= 5

	oReport:FillRect({nRow , nCol , nHeight , nWidth}, oBrushBorder)
	oReport:FillRect({nRow + nSizeBorder , nCol + nSizeBorder , nHeight - nSizeBorder , nWidth - nSizeBorder}, oBrushContent)

Return

/*/{Protheus.doc} GetCboxVal
Retorna o valor de um combo
@type function
@author Rodrigo Godinho
@since 12/01/2024
@param cKeyCbox, character, Valor do código do combo
@param cFieldCbox, character, Campo do combo
@return character, Descricao do item do combo
/*/
Static Function GetCboxVal(cKeyCbox, cFieldCbox)
    Local cRet		:= ""
    Local aArea		:= GetArea()
    Local aValues	:= {}
    Local nPosKey	:= 1
    
	Default cKeyCbox	:= ""
    Default cFieldCbox	:= ""
     
    If !Empty(cFieldCbox) .And. !Empty(cKeyCbox)
		aValues := RetSX3Box(GetSX3Cache(cFieldCbox, "X3_CBOX"),,,1)
		If (nPosKey := aScan(aValues, {|x| AllTrim(x[2]) == AllTrim(cKeyCbox)})) > 0
			cRet := aValues[nPosKey][3]
		EndIf			
    EndIf
     
    RestArea(aArea)
Return cRet

/*/{Protheus.doc} GetFornecedores
Retorna os fornecedores do contrato
@type function
@author Rodrigo Godinho
@since 12/01/2024
@param cNumContrato, character, Contrato
@param cRevContrato, character, Revisao
@return array, Array de fornecedores
/*/
Static Function GetFornecedores(cNumContrato, cRevContrato)
	Local aRet		:= {}
	Local aArea		:= GetArea()
	Local aAreaCNC	:= CNC->(GetArea())
	Local cKey		:= ""
	Local cNomeForn	:= ""

	Default cNumContrato	:= ""
	Default cRevContrato	:= ""

	cKey := xFilial("CNC") + AvKey(cNumContrato, "CNC_NUMERO") + AvKey(cRevContrato, "CNC_REVISA")

	CNC->(dbSetOrder(1))
	If CNC->(MSSeek( cKey ))
		While CNC->CNC_FILIAL + CNC->CNC_NUMERO + CNC->CNC_REVISA == cKey
			cNomeForn := GetAdvFVal("SA2", "A2_NOME", xFilial("SA2") + CNC->CNC_CODIGO + CNC->CNC_LOJA, 1, "", .T.)
			aAdd(aRet, {CNC->CNC_CODIGO, CNC->CNC_LOJA, cNomeForn})
			CNC->(dbSkip())
		EndDo
	EndIf
	
	RestArea(aAreaCNC)
	RestArea(aArea)
Return aRet

/*/{Protheus.doc} GetArrLines
Retorna array com as linhas de um texto de acordo com o tamanho definido por linha
@type function
@author Rodrigo Godinho
@since 12/01/2024
@param cText, character, Texto
@param nSizeLine, numeric, Tamanho da linha
@return array, Array de linhas
/*/
Static Function GetArrLines(cText, nSizeLine)
	Local aRet		:= {}
	Local nQtdLines	:= ""
	Local nI		:= 0

	Default cText		:= ""
	Default nSizeLine	:= 100
     
    nQtdLines := MLCount(cText, nSizeLine)
     
    For nI := 1 to nQtdLines
    	aAdd(aRet, MemoLine(cText, nSizeLine, nI))
    Next

Return aRet

/*/{Protheus.doc} GetMedStDescr
Retorna o status da da medicao
@type function
@author Rodrigo Godinho
@since 16/01/2024
@param cStatus, character, Status
@return character, Descricao do status
/*/
Static Function GetMedStDescr(cStatus)
	Local cRet	:= ""

	Default cStatus	:= CND->CND_SITUAC

	If Alltrim(cStatus) == 'A'"
		cRet := "Medição em Aberto"
	ElseIf Alltrim(cStatus) == 'B'"
		cRet := "Medição Bloqueada"
	ElseIf Alltrim(cStatus) == 'R'"
		cRet := "Medição Rejeitada"
	ElseIf Alltrim(cStatus) == 'C'"
		cRet := "Medição Cancelada"
	ElseIf Alltrim(cStatus) == 'E'"
		cRet := "Medição Encerrada"
	ElseIf Alltrim(cStatus) == 'FA'
		cRet := "Aut. Fornec. em Aberto"
	ElseIf Alltrim(cStatus) == 'FE'
		cRet := "Aut. Fornec Encerrada"
	ElseIf Alltrim(cStatus) == 'DT'
		cRet := "Medição Totalmente Devolvida"
	ElseIf Alltrim(cStatus) == 'DP'
		cRet := "Medição Parcialmente Devolvida"
	ElseIf Empty(cStatus)"
		cRet := "Medição oriunda do CNTA120"
	ElseIf Alltrim(cStatus) == 'SA'
		cRet := "Medição de Serviço em Aberto"
	EndIf
	
Return cRet

/*/{Protheus.doc} PosicUltMed
Posiciona na ultima medicao para o contrato e revisão informados
@type function
@author Rodrigo Godinho
@since 17/01/2024
@param cNumContrato, character, Contrato
@param cRevContrato, character, Revisãao
@return logical, Se foi possivel posicionar
/*/
Static Function PosicUltMed(cNumContrato, cRevContrato)
	Local lRet		:= .F.
	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()

	BeginSQL Alias cAliasQry
		SELECT TOP 1 R_E_C_N_O_ REC_CND
		FROM %Table:CND%
		WHERE CND_FILIAL = %xFilial:CND%
			AND CND_CONTRA = %Exp:cNumContrato%
			AND CND_REVISA = %Exp:cRevContrato%
			AND %NotDel%
		ORDER BY R_E_C_N_O_ DESC
	EndSQL

	If !(cAliasQry)->(Eof())
		CND->(dbGoTo((cAliasQry)->REC_CND))
		lRet := !(CND->(Eof()))
	EndIf
	(cAliasQry)->(dbCloseArea())

	If aArea[1] != "CND"
		RestArea(aArea)
	EndIf
Return lRet

/*/{Protheus.doc} GetItensMed
Retorna itens da medicao
@type function
@author Rodrigo Godinho
@since 16/01/2024
@param cNumMedicao, character, Medicao
@param cNumContrato, character, Contrato
@param cRevContrato, character, Revisao
@param lFiltQtdZero, logical, Se filtra itens com quantidade zero
@return array, Dados dos itens da medicao
/*/
Static Function GetItensMed(cNumMedicao, cNumContrato, cRevContrato, lFiltQtdZero)
	Local aRet		:= {}
	Local aItem		:= {}
	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()
	Local cAuxWhere	:= ""

	Default cNumMedicao		:= ""
	Default cNumContrato	:= ""
	Default cRevContrato	:= ""
	Default lFiltQtdZero	:= .F.

	cAuxWhere += "%"
	If lFiltQtdZero
		cAuxWhere += " AND CNE_QUANT > 0 "
	EndIf
	cAuxWhere += "%"

	BeginSQL Alias cAliasQry
		SELECT CNE_NUMERO, CNE_ITEM, CNE_PRODUT, B1_DESC, CNE_QUANT, CNE_VLUNIT, CNE_VLTOT, B1_UM
		FROM %Table:CNE% CNE
		JOIN %Table:SB1% SB1 ON B1_FILIAL = %xFilial:SB1% AND B1_COD = CNE_PRODUT AND SB1.%NotDel%
		WHERE CNE_FILIAL = %xFilial:CNE%
			AND CNE_CONTRA = %Exp:cNumContrato%
			AND CNE_REVISA = %Exp:cRevContrato%
			AND CNE_NUMMED = %Exp:cNumMedicao%
			AND CNE.%NotDel%
			%Exp:cAuxWhere%
		ORDER BY CNE_FILIAL, CNE_CONTRA, CNE_REVISA, CNE_NUMMED, CNE_NUMERO, CNE_ITEM
	EndSQL

	While !(cAliasQry)->(Eof())
		aAdd(aItem, (cAliasQry)->CNE_NUMERO)
		aAdd(aItem, (cAliasQry)->CNE_ITEM)
		aAdd(aItem, (cAliasQry)->CNE_PRODUT)
		aAdd(aItem, (cAliasQry)->B1_DESC)
		aAdd(aItem, (cAliasQry)->B1_UM)
		aAdd(aItem, (cAliasQry)->CNE_QUANT)
		aAdd(aItem, (cAliasQry)->CNE_VLUNIT)
		aAdd(aItem, (cAliasQry)->CNE_VLTOT)

		aAdd(aRet, aClone(aItem))
		
		aSize(aItem, 0)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	
	RestArea(aArea)
Return aRet

/*/{Protheus.doc} ControlaDoc
Se tipo do contrato controla medicao
@type function
@author Rodrigo Godinho
@since 18/01/2024
@param cTipoContrato, character, Tipo do contrato
@return logical, Se controla documentos
/*/
Static Function ControlaDoc(cTipoContrato)
	Local lRet	:= .F.
	Local aArea	:= GetArea()

	Default cTipoContrato	:= ""

	lRet := AllTrim(GetAdvFVal("CN1", "CN1_CTRDOC", xFilial("CN1")+AvKey(cTipoContrato, "CN1_CODIGO"), 1, "", .F.)) == "1"

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} GetDocsPend
Retorna documentos pendentes
@type function
@author Rodrigo Godinho
@since 18/01/2024
@param cNumContrato, character, Contrato
@param dDataRef, date, Data de referencia
@return array, Dados dos documentos pendentes
/*/
Static Function GetDocsPend(cNumContrato, dDataRef)
	Local aRet		:= {}
	Local aDoc		:= {}
	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()

	Default cNumContrato	:= ""
	Default dDataRef		:= dDataBase

	BeginSQL Alias cAliasQry
		COLUMN CNK_DTVALI AS DATE
		SELECT CNK_CODIGO, CNK_DESCRI, CNK_DTVALI
		FROM %Table:CNK% CNK
		WHERE CNK_FILIAL = %xFilial:CNK%
			AND CNK_CONTRA = %Exp:cNumContrato%
			AND CNK_DTVALI < %Exp:dDataRef%
			AND CNK.%NotDel%
		ORDER BY CNK_FILIAL, CNK_CODIGO
	EndSQL

	While !(cAliasQry)->(Eof())
		aAdd(aDoc, (cAliasQry)->CNK_CODIGO)
		aAdd(aDoc, (cAliasQry)->CNK_DESCRI)
		aAdd(aDoc, (cAliasQry)->CNK_DTVALI)

		aAdd(aRet, aClone(aDoc))
		
		aSize(aDoc, 0)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	
	RestArea(aArea)
Return aRet

/*/{Protheus.doc} CalcVencto
Calcula vencimento
@type function
@author Rodrigo Godinho
@since 19/01/2024
@param cCondPg, character, Condicao de pagamento
@param dDataRef, date, Data de referencia
@return date, Data de vencimento
/*/
Static Function CalcVencto(cCondPg, dDataRef)
	Local dRet			:= CToD("")
	Local aArea			:= GetArea()
	Local aDatasPgto	:= {}

	Default cCondPg		:= ""
	Default dDataRef	:= dDataBase

	aDatasPgto := Condicao(1, cCondPg, , dDataRef)
	If ValType(aDatasPgto) == "A" .And. Len(aDatasPgto) > 0
		dRet += aDatasPgto[1][1]
	EndIf	
	
	RestArea(aArea)
Return dRet

/*/{Protheus.doc} GetPedVcto
Obtem o vencimento se tem pedido de compra
@type function
@author Rodrigo Godinho
@since 19/01/2024
@param cNumMedicao, character, Medicao
@param cNumContrato, character, Contrato
@param cRevContrato, character, Revisao
@return date, Vencimento pelo titulo da fatura associada ao pedido
/*/
Static Function GetPedVcto(cNumMedicao, cNumContrato, cRevContrato)
	Local dRet		:= CToD("")
	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()

	Default cNumMedicao		:= ""
	Default cNumContrato	:= ""
	Default cRevContrato	:= ""

	BeginSQL Alias cAliasQry
		COLUMN E2_VENCREA AS DATE
		SELECT DISTINCT TOP 1 E2_VENCREA
		FROM %Table:SD1% SD1
		JOIN %Table:SE2% SE2 ON E2_FILIAL = %xFilial:SE2% AND E2_PREFIXO = D1_SERIE AND E2_NUM = D1_DOC AND E2_FORNECE = D1_FORNECE AND E2_LOJA = D1_LOJA AND SE2.%NotDel%
		JOIN %Table:SC7% SC7 ON C7_FILIAL = %xFilial:SC7% AND C7_NUM = D1_PEDIDO AND C7_ITEM = D1_ITEMPC AND SC7.%NotDel%
		JOIN %Table:CNE% CNE ON CNE_FILIAL = %xFilial:CNE% AND CNE_PEDIDO = C7_NUM AND CNE.%NotDel%
		JOIN %Table:CND% CND ON CND_FILIAL = %xFilial:CND% AND CND_NUMMED = CNE_NUMMED AND CND.%NotDel%
		WHERE D1_FILIAL = %xFilial:SD1%
			AND D1_PEDIDO <> ' '
			AND CNE_CONTRA = %Exp:cNumContrato%
			AND CNE_REVISA = %Exp:cRevContrato%
			AND CNE_NUMMED = %Exp:cNumMedicao%
			AND SD1.%NotDel%
		ORDER BY E2_VENCREA
	EndSQL

	If !(cAliasQry)->(Eof())
		dRet := (cAliasQry)->E2_VENCREA
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	RestArea(aArea)
Return dRet

/*/{Protheus.doc} GetTitVcto
Retorna o vencimento pelo título, para medições que geram titulo e não pedido
@type function
@author Rodrigo Godinho
@since 19/01/2024
@param cNumMedicao, character, Medicao
@param cNumContrato, character, Contrato
@param cRevContrato, character, Revisao
@return date, Vencimento
/*/
Static Function GetTitVcto(cNumMedicao, cNumContrato, cRevContrato)
	Local dRet		:= CToD("")
	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()

	Default cNumMedicao		:= ""
	Default cNumContrato	:= ""
	Default cRevContrato	:= ""

	BeginSQL Alias cAliasQry
		COLUMN E2_VENCREA AS DATE
		SELECT DISTINCT TOP 1 E2_VENCREA
		FROM %Table:SE2% SE2
		JOIN %Table:CND% CND ON CND_FILIAL = %xFilial:CND% AND CND_NUMMED = E2_MEDNUME AND CND_CONTRA = E2_MDCONTR AND CND_REVISA = E2_MDREVIS AND CND.%NotDel%
		WHERE E2_FILIAL = %xFilial:SE2%
			AND CND_CONTRA = %Exp:cNumContrato%
			AND CND_REVISA = %Exp:cRevContrato%
			AND CND_NUMMED = %Exp:cNumMedicao%
			AND SE2.%NotDel%
		ORDER BY E2_VENCREA
	EndSQL

	If !(cAliasQry)->(Eof())
		dRet := (cAliasQry)->E2_VENCREA
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	RestArea(aArea)
Return dRet

/*/{Protheus.doc} GetPedTit
Retorna se a medicao gerara pedido, titulo ou ambos
@type function
@author Rodrigo Godinho
@since 19/01/2024
@param cNumMedicao, character, Medicao
@param cNumContrato, character, Contrato
@param cRevContrato, character, Revisao
@return character, Tipo de documento gerado
/*/
Static Function GetPedTit(cNumMedicao, cNumContrato, cRevContrato)
	Local cRet		:= ""
	Local aArea		:= GetArea()
	Local cAliasQry	:= GetNextAlias()

	Default cNumMedicao		:= ""
	Default cNumContrato	:= ""
	Default cRevContrato	:= ""

	BeginSQL Alias cAliasQry
		SELECT MIN(CNE_PEDTIT) MIN_PEDTIT, MAX(CNE_PEDTIT) MAX_PEDTIT
		FROM %Table:CNE%
		WHERE CNE_FILIAL = %xFilial:CN3%
			AND CNE_CONTRA = %Exp:cNumContrato%
			AND CNE_REVISA = %Exp:cRevContrato%
			AND CNE_NUMMED = %Exp:cNumMedicao%
			AND CNE_PEDTIT <> ' '
			AND %NotDel%
	EndSQL

	If !(cAliasQry)->(Eof())
		If (cAliasQry)->MIN_PEDTIT == (cAliasQry)->MAX_PEDTIT
			cRet := (cAliasQry)->MIN_PEDTIT
		Else
			cRet := "A"
		EndIf
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	RestArea(aArea)
Return cRet

/*/{Protheus.doc} GetDtVencto
Obtem o vencimento de uma medicao
@type function
@author Rodrigo Godinho
@since 19/01/2024
@param cNumMedicao, character, Medicao
@param cNumContrato, character, Contrato
@param cRevContrato, character, Revisao
@param cCondPg, character, Condicao de pagamento
@param dDataRef, date, Data de referencia
@return date, Data de vencimento
/*/
Static Function GetDtVencto(cNumMedicao, cNumContrato, cRevContrato, cCondPg, dDataRef)
	Local dRet		:= CToD("")
	Local cPedTit	:= GetPedTit(cNumMedicao, cNumContrato, cRevContrato)
	Local dAuxPed	:= CToD("")
	Local dAuxTit	:= CToD("")

	If cPedTit == "1"
		dRet := GetPedVcto(cNumMedicao, cNumContrato, cRevContrato)
	ElseIf cPedTit == "2"
		dRet := GetTitVcto(cNumMedicao, cNumContrato, cRevContrato)
	ElseIf cPedTit == "A"
		dAuxPed := GetPedVcto(cNumMedicao, cNumContrato, cRevContrato)
		dAuxTit := GetTitVcto(cNumMedicao, cNumContrato, cRevContrato)
		If !Empty(dAuxPed) .And. !Empty(dAuxTit)
			dRet := Min(dAuxPed, dAuxTit)
		ElseIf !Empty(dAuxPed)
			dRet := dAuxPed
		ElseIf !Empty(dAuxTit)
			dRet := dAuxTit
		EndIf
	EndIf

	If Empty(dRet)
		dRet := CalcVencto(cCondPg, dDataRef)
	EndIf
Return dRet

/*/{Protheus.doc} GetMedAnteriores
Retorna dados de medições anteriores
@type function
@author Rodrigo Godinho
@since 17/01/2024
@param cNumMedicao, character, Medicao
@param cNumContrato, character, Contrato
@param cRevContrato, character, Revisao
@param nLimite, numeric, Limite de medições a retornar
@return array, Dados das medições
/*/
Static Function GetMedAnteriores(cNumMedicao, cNumContrato, cRevContrato, nLimite)
	Local aRet				:= {}
	Local aMedicao			:= {}
	Local aArea				:= GetArea()
	Local aAreaCND			:= CND->(GetArea())
	Local cAliasQry			:= GetNextAlias()
	Local cAuxTopSel		:= ""

	Default cNumMedicao		:= ""
	Default cNumContrato	:= ""
	Default cRevContrato	:= ""
	Default nLimite			:= 5

	cAuxTopSel += "%"
	If nLimite > 0
		cAuxTopSel += " TOP " + cValToChar(Int(nLimite)) + " "
	EndIf
	cAuxTopSel += "%"

	BeginSQL Alias cAliasQry
		SELECT  %Exp:cAuxTopSel% R_E_C_N_O_ REC_CND
		FROM %Table:CND% CND
		WHERE CND_FILIAL = %xFilial:CND%
			AND CND_CONTRA = %Exp:cNumContrato%
			AND CND_REVISA = %Exp:cRevContrato%
			AND CND_NUMMED <> %Exp:cNumMedicao%
			AND CND.%NotDel%
		ORDER BY CND_FILIAL, CND_NUMMED DESC
	EndSQL

	While !(cAliasQry)->(Eof())
		CND->(dbGoTo((cAliasQry)->REC_CND))

		aAdd(aMedicao, CND->CND_NUMMED)
		aAdd(aMedicao, CND->CND_DTFIM)
		aAdd(aMedicao, GetDtVencto(CND->CND_NUMMED, CND->CND_CONTRA, CND->CND_REVISA, CND->CND_CONDPG, Iif(Empty(CND->CND_DTFIM),dDataBase,CND->CND_DTFIM)))
		aAdd(aMedicao, CND->CND_COMPET)
		aAdd(aMedicao, CND->CND_VLLIQD)
		aAdd(aMedicao, CND->CND_RETCAC)
		aAdd(aMedicao, CND->CND_DESCME)
		aAdd(aMedicao, CND->CND_VLMULT)
		aAdd(aMedicao, CND->CND_VLBONI)
		aAdd(aMedicao, CND->CND_VLTOT)

		aAdd(aRet, aClone(aMedicao))
		
		aSize(aMedicao, 0)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	
	RestArea(aAreaCND)
	RestArea(aArea)
Return aRet

/*/{Protheus.doc} GetAlcMed
Retorna dados de alçada
@type function
@author Rodrigo Godinho
@since 22/01/2024
@param cNumMedicao, character, Medicao
@return array, Dados da alçada da medicao
/*/
Static Function GetAlcMed(cNumMedicao)
	Local aRet			:= {}
	Local aAprovacao	:= {}
	Local aArea			:= GetArea()
	Local cAliasQry		:= GetNextAlias()
	Local cAuxLike		:= ""
	Local cAuxWNum		:= ""
	Local cDescrSt		:= ""

	Default cNumMedicao	:= ""

	cAuxWNum += AvKey(cNumMedicao, "CR_NUM")
	cAuxLike += Alltrim(CND->CND_NUMMED) + "%"

	BeginSQL Alias cAliasQry
		COLUMN CR_DATALIB AS DATE
		SELECT DISTINCT AK_NOME, CR_USER, CR_USERLIB, CR_APROV, CR_NIVEL, CR_DATALIB, CR_STATUS
		FROM %Table:SCR% SCR
		JOIN %Table:SAK% SAK ON AK_FILIAL = %xFilial:SAK% AND AK_COD = CR_APROV AND AK_USER = CR_USER AND SAK.%NotDel%
		WHERE CR_FILIAL = %xFilial:SCR%
			AND (
				(CR_TIPO = 'MD' AND CR_NUM = %Exp:cAuxWNum%)
				OR
				(CR_TIPO = 'IM' AND CR_NUM LIKE %Exp:cAuxLike%)
			)
			AND SCR.%NotDel%
		ORDER BY CR_NIVEL, CR_DATALIB
	EndSQL

	While !(cAliasQry)->(Eof())
		aAdd(aAprovacao, (cAliasQry)->AK_NOME)
		aAdd(aAprovacao, (cAliasQry)->CR_NIVEL)
		aAdd(aAprovacao, (cAliasQry)->CR_DATALIB)

		If AllTrim((cAliasQry)->CR_STATUS) == '01'
			cDescrSt := "Pendente em níveis anteriores"
		ElseIf AllTrim((cAliasQry)->CR_STATUS) == '02'
			cDescrSt := "Pendente"
		ElseIf AllTrim((cAliasQry)->CR_STATUS) == '03'
			cDescrSt := "Aprovado"
		ElseIf AllTrim((cAliasQry)->CR_STATUS) == '04'
			cDescrSt := "Bloqueado"
		ElseIf AllTrim((cAliasQry)->CR_STATUS) == '05'
			cDescrSt := "Aprovado/rejeitado pelo nível"
		ElseIf AllTrim((cAliasQry)->CR_STATUS) == '06'
			cDescrSt := "Rejeitado"
		ElseIf AllTrim((cAliasQry)->CR_STATUS) == '07'
			cDescrSt := "Doc. Rejeitado/Bloqueado p/ outro usuário"
		EndIf
		
		aAdd(aAprovacao, cDescrSt)

		aAdd(aRet, aClone(aAprovacao))
		
		aSize(aAprovacao, 0)
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())
	
	RestArea(aArea)	
Return aRet

/*/{Protheus.doc} GetImage
Retorna imagem do logo do protheus
@type function
@author Rodrigo Godinho
@since 23/01/2024
@param cCodEmp, character, Empresa
@param cCodFil, character, Filial
@return character, Imagem
/*/
Static Function GetImage(cCodEmp, cCodFil)
	Local cRet		:= ""

	Default cCodEmp	:= cEmpAnt
	Default cCodFil	:= cFilAnt

	If File("LGMID" + AllTrim(cEmpAnt) + AllTrim(cFilAnt) + ".PNG") 
		cRet := "LGMID" + AllTrim(cEmpAnt) + AllTrim(cFilAnt) + ".PNG"
	ElseIf File("LGMID" + AllTrim(cEmpAnt) + ".PNG") 
		cRet := "LGMID" + AllTrim(cEmpAnt) + ".PNG"
	ElseIf File("LGMID.PNG") 
		cRet := "LGMID.PNG"
	EndIf

Return cRet

/*/{Protheus.doc} SomaMedicoes
Soma as medições de um contrato
@type function
@author Rodrigo Godinho
@since 24/01/2024
@param cNumContrato, character, Contrato
@param cRevContrato, character, Revisão
@return numeric, Soma das medições
/*/
Static Function SomaMedicoes(cNumContrato, cRevContrato)
	Local nREt				:= 0
	Local aArea				:= GetArea()
	Local cAliasQry			:= GetNextAlias()

	Default cNumContrato	:= ""
	Default cRevContrato	:= ""

	BeginSQL Alias cAliasQry
		SELECT SUM(CND_VLTOT) SOMA_MEDIC
		FROM %Table:CND% CND
		WHERE CND_FILIAL = %xFilial:CND%
			AND CND_CONTRA = %Exp:cNumContrato%
			AND CND_REVISA = %Exp:cRevContrato%
			AND CND.%NotDel%
	EndSQL

	If !(cAliasQry)->(Eof())
		nRet := (cAliasQry)->SOMA_MEDIC
	EndIf
	(cAliasQry)->(dbCloseArea())
	
	RestArea(aArea)
Return nRet

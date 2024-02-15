#Include 'Protheus.ch'
//////////////////////////////////////////////////////////////////////////
///  Inclusao IntegraГЦo Z10 Maximo - Everton Forti - 10/2018	       ///
//   MXWO - Transferencia ao Armazem                                  ///
//////////////////////////////////////////////////////////////////////////
User Function MA261TRD3()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Recebe os identificadores Recno() gerados na tabela SD3      Ё
//Ё para que seja feito o posicionamento                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
 /*	
Local aRecSD3 := PARAMIXB[1]
Local nX := 1

IF CEMPANT == "31" ////SuperGetMv("MV_UFILMX") = "31"

	For nX := 1 To Len(aRecSD3)
		
		SD3->(DbGoto(aRecSD3[nX][1])) // Requisicao RE4
		//зддддддддддддддддддддддддддддддд©
		//Ё Customizacoes de usuario      Ё
		//юддддддддддддддддддддддддддддддды
		DBSELECTAREA("Z10")
		DBSETORDER(1)
		if reclock("Z10",.T.)
			//GRAVA TABELA DE INTEGRAгцO MAXIMO
			Z10->Z10_FILIAL 	:= xFilial("SD3")
			Z10->Z10_INREG 	 	:= "SD3"
			Z10->Z10_DATA 		:= DATE()
			Z10->Z10_USUARI 	:=  RetCodUsr()
			Z10->Z10_HORA  		:= time()
			Z10->Z10_MOVIME		:= '1' //Inclusao
			Z10->Z10_B1COD 		:= SD3->D3_COD
			Z10->Z10_B1DESC		:= POSICIONE("SB1",1,xFILIAL("SB1")+SD3->D3_COD,"B1_DESC")
			Z10->Z10_B1UM  		:= SD3->D3_UM
			Z10->Z10_D3QTD 		:= SD3->D3_QUANT
			Z10->Z10_D3ATEN		:= SD3->D3_UATENDI
			Z10->Z10_D3OS		:= SD3->D3_UOS
			Z10->Z10_D3DOC		:= SD3->D3_DOC
			Z10->Z10_ORIGEM		:= "MATA261" 
			Z10->Z10_DESTIN		:= "MXWO"
			ENDIF
			MsUnlock()
		
		SD3->(DbGoto(aRecSD3[nX][2])) // Devolucao DE4
		//зддддддддддддддддддддддддддддддд©
		//Ё Customizacoes de usuario      Ё
		//юддддддддддддддддддддддддддддддды
		
	Next nX
endif
*/
Return Nil 



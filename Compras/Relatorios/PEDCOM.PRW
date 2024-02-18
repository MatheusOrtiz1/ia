#include 'protheus.ch'
#INCLUDE "rwmake.ch"
#INCLUDE "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºDesc.     ³ PEDIDO DE COMPRAS (Emissao em formato Grafico)             º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PEDCOM()

		Private MVUSC7OBS	:= SUPERGETMV( "MV_USC7OBS", .F., .F. )
		Private	lEnd		:= .f.,;
				aAreaSC7	:= SC7->(GetArea()),;
				aAreaSA2	:= SA2->(GetArea()),;
				aAreaSA5	:= SA5->(GetArea()),;   
				aAreaSF4	:= SF4->(GetArea()),;
	 			cPerg		:= 'R_PEDCOM  '

		AjustaSX1(cPerg)

		//If	( ! Pergunte(cPerg,.T.) )
		//	Return
		//Else
			Private	cNumPed  	:= SC7->C7_NUM		//mv_par01
			Private	cObserv1	:= ""
			Private	cObserv2	:= ""
			Private	cObserv3	:= ""
			Private	cObserv4	:= "" 			
			Private	cObserv5	:= ""
			Private	cObserv6	:= ""
			Private	cObserv7	:= ""
			Private	cObserv8	:= ""
			
			Private	lPrintCodFor:= .T.				// Imprime o Codigo do produto no fornecedor ?
		//EndIf
                
		Private _lSub    := .T.
		Private _nNrPg	:= 0      
		Private _cMenHor 

		IF MVUSC7OBS
			DBSELECTAREA( "Z33" )
			DBSETORDER( 1 )
			IF DBSEEK( xFilial("Z33")+"0001")
				_cMenHor := Z33->Z33_OBS
			ENDIF
		ENDIF

		IF EMPTY( _cMenHor )
			_cMenHor := '******Favor enviar o XML da nota. NÃO ACEITAMOS notas fiscais emitidas com data posterior ao dia 20 de cada mês! '
			_cMenHor += 'NÃO REALIZAMOS PAGAMENTO com data posterior ao dia 27 de cada mês! Os materiais serão inspecionados, caso não estejam em conformidade, '
			_cMenHor += 'serão rejeitados e devolvidos ao fornecedor para reposição ou desconto no pagamento, conforme critério do setor de suprimentos.******' 
		ENDIF

		DbSelectArea('SC7')
		SC7->(DbSetOrder(1))
		If	( ! SC7->(DbSeek(xFilial('SC7') + cNumPed)) )
			Help('',1,'R_PEDCOM  ',,OemToAnsi('Pedido não encontrado.'),1)
			Return .f.
		EndIf

		Processa({ |lEnd| xPrintRel(),OemToAnsi('Gerando o relatório.')}, OemToAnsi('Aguarde...'))
		
		RestArea(aAreaSC7)
		RestArea(aAreaSA2)
		RestArea(aAreaSA5)
		RestArea(aAreaSF4)

Return


Static Function xPrintRel()
Private	oPrint		:= TMSPrinter():New(OemToAnsi('Pedido de Compras')),;
		oBrush		:= TBrush():New(,CLR_HGRAY),;
		cFileLogo	:= GetSrvProfString('Startpath','') +  'LGMID'+SUBSTR(CNUMEMP,1,2)+'.png' ,;		//cFileLogo	:= GetSrvProfString('Startpath','') + 'lgrl' + AllTrim(cEmpAnt) + '.bmp',;
		oFont07		:= TFont():New('Courier New',07,07,,.F.,,,,.T.,.F.),;
		oFont08		:= TFont():New('Courier New',08,08,,.F.,,,,.T.,.F.),;
		oFont09		:= TFont():New('Tahoma',09,09,,.F.,,,,.T.,.F.),;
		oFont10		:= TFont():New('Tahoma',10,10,,.F.,,,,.T.,.F.),;
		oFont10n	:= TFont():New('Tahoma',10,10,,.T.,,,,.T.,.F.),;
		oFont11		:= TFont():New('Tahoma',11,11,,.F.,,,,.T.,.F.),;
		oFont12		:= TFont():New('Tahoma',12,12,,.T.,,,,.T.,.F.),;
		oFont12n	:= TFont():New('Tahoma',12,12,,.F.,,,,.T.,.F.),;
		oFont13		:= TFont():New('Tahoma',13,13,,.T.,,,,.T.,.F.),;
		oFont14		:= TFont():New('Tahoma',14,14,,.T.,,,,.T.,.F.),;
		oFont15		:= TFont():New('Courier New',15,15,,.T.,,,,.T.,.F.),;
		oFont18		:= TFont():New('Arial',18,18,,.T.,,,,.T.,.T.),;
		oFont16		:= TFont():New('Arial',16,16,,.T.,,,,.T.,.F.),;
		oFont20		:= TFont():New('Arial',20,20,,.F.,,,,.T.,.F.),;
		oFont22		:= TFont():New('Arial',22,22,,.T.,,,,.T.,.F.)

Private	lFlag		:= .t.,;	// Controla a impressao do fornecedor
		nLinha		:= 3000 - 1000,;	// Controla a linha por extenso
		nLinFim		:= 0,;		// Linha final para montar a caixa dos itens
		lPrintDesTab:= .f.,;	// Imprime a Descricao da tabela (a cada nova pagina)
		cRepres		:= Space(80)

Private	_nQtdReg	:= 0,;		// Numero de registros para intruir a regua
		_nValMerc 	:= 0,;		// Valor das mercadorias
		_nValIPI	:= 0,;		// Valor do I.P.I.
		_nValDesc	:= 0,;		// Valor de Desconto
		_nTotAcr	:= 0,;		// Valor total de acrescimo
		_nTotSeg	:= 0,;		// Valor de Seguro
		_nTotFre	:= 0,;		// Valor de Frete
		_nTotIcmsRet:= 0,;		// Valor do ICMS Retido
        _nICMS		:= 0,;        
        _nContL		:= 0        
              
		DbSelectArea('SA2')
		SA2->(DbSetOrder(1))
		If	! SA2->(DbSeek(xFilial('SA2')+SC7->(C7_FORNECE+C7_LOJA)))
			Help('',1,'REGNOIS')
			Return .f.
		EndIf
		
		oPrint:SetLandscape() 
		oPrint:setPaperSize(9)
		oPrint:Setup()

		cSELECT :=	'SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_EMISSAO, SC7.C7_FORNECE, SC7.C7_LOJA, '+;
					'SC7.C7_ITEM, SC7.C7_PRODUTO, SC7.C7_DESCRI, SC7.C7_QUANT, '+;   
					'SC7.C7_UM, SC7.C7_SEGUM, SC7.C7_QTSEGUM, SC7.C7_DATPRF, '+;
					'SC7.C7_PRECO, SC7.C7_IPI, SC7.C7_TOTAL, SC7.C7_VLDESC, SC7.C7_DESPESA, '+;
					'SC7.C7_SEGURO, SC7.C7_VALFRE, SC7.C7_TES, SC7.C7_ICMSRET, SC7.C7_OBS, '+;
					'SC7.C7_CONAPRO, SC7.C7_VALICM,  SC7.C7_CC,  SC7.C7_CO,  SC7.C7_TPFRETE, SC7.C7_NUMSC  '
		cFROM   :=	RetSqlName('SC7') + ' SC7 '
		cWHERE  :=	'SC7.D_E_L_E_T_ <>   '+CHR(39) + '*'            +CHR(39) + ' AND '+;
					'SC7.C7_FILIAL  =    '+CHR(39) + xFilial('SC7') +CHR(39) + ' AND '+;
					'SC7.C7_NUM     =    '+CHR(39) + cNumPed        +CHR(39) 
		cORDER  :=	'SC7.C7_FILIAL, SC7.C7_ITEM '
		cQuery  :=	' SELECT '   + cSELECT + ; 
					' FROM '     + cFROM   + ;
					' WHERE '    + cWHERE  + ;
					' ORDER BY ' + cORDER

		TCQUERY cQuery NEW ALIAS 'TRA'

		If	! USED()
			MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
		EndIf

		DbSelectArea('TRA')
		Count to _nQtdReg
		ProcRegua(_nQtdReg)
		TRA->(DbGoTop())

		While 	TRA->( ! Eof() )

				xVerPag()

				If	( lFlag )

					oPrint:Say(0370,0100,OemToAnsi('Fornecedor:'),oFont13)
					oPrint:Say(0370,0430,+ '['+AllTrim(SA2->A2_COD)+'/'+AllTrim(SA2->A2_LOJA)+'] ' + AllTrim(SA2->A2_NOME),oFont13)					
					
					oPrint:Say(0430,0100,OemToAnsi('Endereço:'),oFont10)
					oPrint:Say(0430,0430,SA2->A2_END,oFont10)
					
					oPrint:Say(0480,0100,OemToAnsi('Município/U.F.:'),oFont10)
					oPrint:Say(0480,0430,AllTrim(SA2->A2_MUN)+'/'+AllTrim(SA2->A2_EST),oFont10)
					oPrint:Say(0480,1000,OemToAnsi('Cep:'),oFont10)
					oPrint:Say(0480,1170,TransForm(SA2->A2_CEP,'@R 99.999-999'),oFont10)					                      
					oPrint:Say(0480,1600,OemToAnsi('CNPJ:'),oFont10)										
					If (SA2->A2_TIPO == "F")                                          
						oPrint:Say(0480,1790,Transform(AllTrim(SA2->A2_CGC),"@R 999.999.999-99"),oFont10)
					Else                                                                                 
						oPrint:Say(0480,1790,Transform(AllTrim(SA2->A2_CGC),"@R 99.999.999/9999-99"),oFont10)
					Endif					
					
					oPrint:Say(0530,0100,OemToAnsi('Telefone:'),oFont10)
					oPrint:Say(0530,0430,SA2->A2_TEL,oFont10)
					oPrint:Say(0530,1000,OemToAnsi('Fax:'),oFont10)
					oPrint:Say(0530,1170,SA2->A2_FAX,oFont10)                    
					oPrint:Say(0530,1600,OemToAnsi('INSC.EST.:'),oFont10)										
					oPrint:Say(0530,1790,AllTrim(SA2->A2_INSCR),oFont10)      
					
					oPrint:Say(0580,0100,OemToAnsi('Dt.Emissão:'),oFont10)
					oPrint:Say(0580,0430,Dtoc(SC7->C7_EMISSAO),oFont10)
					oPrint:Say(0580,1000,OemToAnsi('Contato:'),oFont10)
					oPrint:Say(0580,1170,SC7->C7_CONTATO,oFont10)
					oPrint:Say(0580,1600,OemToAnsi('Cond.Pgto:'),oFont10)
					oPrint:Say(0580,1790,POSICIONE('SE4',1,xFilial('SE4')+SC7->C7_COND,'E4_DESCRI'),oFont10)
					
					lFlag := .f.

				EndIf
				
				If	( lPrintDesTab )          
				
					oPrint:Line(nLinha,100,nLinha,3300)
					oPrint:Line(nLinha,100,nLinha+70,100)
					oPrint:Line(nLinha,200,nLinha+70,200) 					
					oPrint:Line(nLinha,510,nLinha+70,510)					
//					oPrint:Line(nLinha,740+140,nLinha+70,740+140)
//					oPrint:Line(nLinha,1390+100,nLinha+70,1390+100)
					                                               
//					oPrint:Line(nLinha,1490+100,nLinha+70,1490+100)
					
//					oPrint:Line(nLinha,1590+230,nLinha+70,1590+230)
					oPrint:Line(nLinha,1840+230,nLinha+70,1840+230)
					oPrint:Line(nLinha,2040+230,nLinha+70,2040+230)
					oPrint:Line(nLinha,2300+230,nLinha+70,2300+230)
					oPrint:Line(nLinha,2560+230,nLinha+70,2560+230)
					oPrint:Line(nLinha,2800+230,nLinha+70,2800+230)
					oPrint:Line(nLinha,3300,nLinha+70,3300)

					oPrint:Say(nLinha,0120,OemToAnsi('ID'),oFont10n)
					oPrint:Say(nLinha,0210,OemToAnsi('CÓDIGO'),oFont10n)					                                                     
//					oPrint:Say(nLinha,0420,OemToAnsi('ID FORNECEDOR'),oFont10n)					
					oPrint:Say(nLinha,0420+140,OemToAnsi('DESCRIÇÃO'),oFont10n)

					oPrint:Say(nLinha,1800+130+250,OemToAnsi('UN'),oFont10n)					                                        
					
					oPrint:Say(nLinha,2050+250+60,OemToAnsi('QTD'),oFont10n)
					oPrint:Say(nLinha,2320+250,OemToAnsi('VLR.UNIT.'),oFont10n)
//					oPrint:Say(nLinha,1850+250,OemToAnsi('IPI (%)'),oFont10n)
//					oPrint:Say(nLinha,2050+250,OemToAnsi('QTD 2aUN'),oFont10n)					
//					oPrint:Say(nLinha,2320+250,OemToAnsi('V.UNIT.2a'),oFont10n)
					oPrint:Say(nLinha,2570+250,OemToAnsi('ENTREGA'),oFont10n)
					oPrint:Say(nLinha,2800+250,OemToAnsi('VLR TOTAL'),oFont10n)
					
					lPrintDesTab := .f.
					nLinha += 70
					oPrint:Line(nLinha,100,nLinha,3300)                   
					
				EndIf

				oPrint:Line(nLinha,100,nLinha+60,100)           
				
				oPrint:Line(nLinha,200,nLinha+60,200)     				
				oPrint:Line(nLinha,510,nLinha+60,510)    
//				oPrint:Line(nLinha,740+140,nLinha+60,740+140)
//				oPrint:Line(nLinha,1390+100,nLinha+60,1390+100) 
				
//				oPrint:Line(nLinha,1490+100,nLinha+60,1490+100)
				
//				oPrint:Line(nLinha,1590+230,nLinha+60,1590+230)
				oPrint:Line(nLinha,1840+230,nLinha+60,1840+230)
				oPrint:Line(nLinha,2040+230,nLinha+60,2040+230)
				oPrint:Line(nLinha,2300+230,nLinha+60,2300+230) 				
				oPrint:Line(nLinha,2560+230,nLinha+60,2560+230)
				oPrint:Line(nLinha,2800+230,nLinha+60,2800+230)
				oPrint:Line(nLinha,3300,nLinha+60,3300)

				oPrint:Say(nLinha,0120,TRA->C7_ITEM,oFont09)
				
				If	( lPrintCodFor )
					DbSelectArea('SA5')
					SA5->(DbSetOrder(1))
					If	SA5->(DbSeek(xFilial('SA5') + SA2->A2_COD + SA2->A2_LOJA + TRA->C7_PRODUTO)) .and. ( ! Empty(SA5->A5_CODPRF) )
						oPrint:Say(nLinha,0240-30,AllTrim(TRA->C7_PRODUTO),oFont09)
						/*
						If TRA->C7_CONAPRO == 'B'
							oPrint:Say(nLinha,0420,'ITEM BLOQUEADO',oFont09)
						Else
							oPrint:Say(nLinha,0420,AllTrim(SA5->A5_CODPRF),oFont09)
						EndIf
						*/
					Else    
						oPrint:Say(nLinha,0240-30,AllTrim(TRA->C7_PRODUTO),oFont09) 
				/*If TRA->C7_CONAPRO == 'B'
							oPrint:Say(nLinha,0420,'ITEM BLOQUEADO',oFont09)
						Else							
							oPrint:Say(nLinha,0420,'N.I.',oFont09)
				EndIf*/
					EndIf
				Else
					oPrint:Say(nLinha,0210,AllTrim(TRA->C7_PRODUTO),oFont09)
				EndIf	
				
				cXDesc:= POSICIONE("SB1",1,xFilial("SB1")+TRA->C7_PRODUTO,"B1_DESC" )
				
				//****************************************************
				//Descrição											 |
				//****************************************************
				oPrint:Say(nLinha,0420+140,SUBSTR(cXDesc,1,100),oFont07) 
				oPrint:Say(nLinha+30,0420+140,SUBSTR(cXDesc,101,100),oFont07)
				oPrint:Say(nLinha+30,0420+140,SUBSTR(cXDesc,201,100),oFont07)
									                                                                 
				oPrint:Say(nLinha,1800+155+250,AllTrim(TRA->C7_UM),oFont09,,,,1)
															
				oPrint:Say(nLinha,2050+155+250,AllTrim(TransForm(TRA->C7_QUANT,'@E 99,999.99')),oFont09,,,,1)
				oPrint:Say(nLinha,2320+185+250,AllTrim(TransForm(TRA->C7_PRECO,'@E 999,999.9999')),oFont09,,,,1)
//				oPrint:Say(nLinha,1850+155+250,AllTrim(TransForm(TRA->C7_IPI,'@E 999,999.99')),oFont09,,,,1)
//				oPrint:Say(nLinha,2050+200+250,AllTrim(TransForm(TRA->C7_QTSEGUM,'@E 999,999.99')),oFont09,,,,1) 
//				oPrint:Say(nLinha,2320+200+250,AllTrim(TransForm(TRA->C7_UVLRSEG,'@E 999,999.99')),oFont09,,,,1) 
				oPrint:Say(nLinha,2560+200+250,AllTrim(Dtoc(Stod(TRA->C7_DATPRF))),oFont09,,,,1)
				oPrint:Say(nLinha,2800+200+250,AllTrim(TransForm(TRA->C7_TOTAL,'@E 999,999.99')),oFont09,,,,1)
				
				nLinha += 60
				oPrint:Line(nLinha,100,nLinha,3300)

				_nValMerc 		+= TRA->C7_TOTAL
				_nValIPI		+= (TRA->C7_TOTAL * TRA->C7_IPI) / 100
				_nValDesc		+= TRA->C7_VLDESC
				_nTotAcr		+= TRA->C7_DESPESA
				_nTotSeg		+= TRA->C7_SEGURO
				_nTotFre		+= TRA->C7_VALFRE
				_nICMS			+= TRA->C7_VALICM
				_cTipFre		:= TRA->C7_TPFRETE
								
				If	( Empty(TRA->C7_TES) )
					_nTotIcmsRet	+= TRA->C7_ICMSRET
				Else
					DbSelectArea('SF4')
					SF4->(DbSetOrder(1))
					If	SF4->(DbSeek(xFilial('SF4') + TRA->C7_TES))
						If	( AllTrim(SF4->F4_INCSOL) == 'S' )
							_nTotIcmsRet	+= TRA->C7_ICMSRET
						EndIf
					EndIf
				EndIf 
								
            _nContL ++
             
                            
			If (_nContL == 1)
				cObserv1 := TRA->C7_OBS
			ElseIf (_nContL == 2)
				cObserv2 := TRA->C7_OBS
			ElseIf (_nContL == 3)
				cObserv3 := TRA->C7_OBS
			ElseIf (_nContL == 4)
				cObserv4 := TRA->C7_OBS

			ElseIf (_nContL == 5)
				cObserv5 := TRA->C7_OBS

			ElseIf (_nContL == 6)
				cObserv6 := TRA->C7_OBS

			ElseIf (_nContL == 7)
				cObserv7 := TRA->C7_OBS

			ElseIf (_nContL == 8)
				cObserv8 := TRA->C7_OBS
			EndIf										
		
		//CENTRO DE CUSTO + NATUREZA
				cXnatur := TRA->C7_CO
				cXcc	:= TRA->C7_CC
		       	
			IncProc()
			TRA->(DbSkip())	
			
		End
		//CENTRO DE CUSTO + NATUREZA
         oPrint:Say(nLinha,100,"Centro de Custo: "+cXcc+"  -  Natureza: "+cXnatur,oFont08)
         nLinha += 80                  
		If !EMPTY(_cTipFre)
			IF _cTipFre == "C"
				oPrint:Say(nLinha,100,'FRETE  -  CIF',oFont08)
				nLinha += 80
			elseif _cTipFre == "F"	
				oPrint:Say(nLinha,100,'FRETE  -  FOB',oFont08)
			Endif
		endif
		
		_lSub    := .F.
		
		xVerPag()

		oPrint:Say(nLinha+10,0490,'*** VALOR ICMS',oFont08)                                       
		oPrint:Say(nLinha+10,1310,'R$' + TransForm(_nICMS,'@E 9,999,999.99') + ' ***',oFont08,,,,1)

		oPrint:Line(nLinha,2070,nLinha+80,2070)
		oPrint:Line(nLinha,2790,nLinha+80,2790)
		oPrint:Line(nLinha,3300,nLinha+80,3300)
		oPrint:Say(nLinha+10,2100,'VALOR MERCADORIAS',oFont10n)                                       
		oPrint:Say(nLinha+10,2800,'R$',oFont10n)                                       		
		oPrint:Say(nLinha+10,3250,TransForm(_nValMerc,'@E 999,999,999,999.99'),oFont10n,,,,1)
		nLinha += 80
		oPrint:Line(nLinha,2070,nLinha,3300)


		xVerPag()

		If	( _nValIpi > 0 )
			oPrint:Line(nLinha,2070,nLinha+80,2070)
			oPrint:Line(nLinha,2790,nLinha+80,2790)
			oPrint:Line(nLinha,3300,nLinha+80,3300)
			oPrint:Say(nLinha+10,2100,'VALOR I. P. I. (+)',oFont10n)
			oPrint:Say(nLinha+10,2800,'R$',oFont10n)
			oPrint:Say(nLinha+10,3250,TransForm(_nValIpi,'@E 999,999,999,999.99'),oFont10n,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,2070,nLinha,3300)
		EndIf

		xVerPag()

		If	( _nValDesc > 0 )
			oPrint:Line(nLinha,2070,nLinha+80,2070)
			oPrint:Line(nLinha,2790,nLinha+80,2790)
			oPrint:Line(nLinha,3300,nLinha+80,3300)
			oPrint:Say(nLinha+10,2100,'VALOR DESCONTO (-)',oFont10n)
			oPrint:Say(nLinha+10,2800,'R$',oFont10n)
			oPrint:Say(nLinha+10,3250,TransForm(_nValDesc,'@E 999,999,999,999.99'),oFont10n,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,2070,nLinha,3300)
		EndIf

		xVerPag()

		If	( _nTotAcr > 0 )
			oPrint:Line(nLinha,2070,nLinha+80,2070)
			oPrint:Line(nLinha,2790,nLinha+80,2790)
			oPrint:Line(nLinha,3300,nLinha+80,3300)
			oPrint:Say(nLinha+10,2100,'VALOR ACRESC. (+)',oFont10n)
			oPrint:Say(nLinha+10,2800,'R$',oFont10n)
			oPrint:Say(nLinha+10,3250,TransForm(_nTotAcr,'@E 999,999,999,999.99'),oFont10n,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,2070,nLinha,3300)
		EndIf

		xVerPag()

		If	( _nTotSeg > 0 )
			oPrint:Line(nLinha,2070,nLinha+80,2070)
			oPrint:Line(nLinha,2790,nLinha+80,2790)
			oPrint:Line(nLinha,3300,nLinha+80,3300)
			oPrint:Say(nLinha+10,2100,'VALOR SEGURO (+)',oFont10n)
			oPrint:Say(nLinha+10,2800,'R$',oFont10n)
			oPrint:Say(nLinha+10,3250,TransForm(_nTotSeg,'@E 999,999,999,999.99'),oFont10n,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,2070,nLinha,3300)
		EndIf

		xVerPag()

		If	( _nTotFre > 0 )
			oPrint:Line(nLinha,2070,nLinha+80,2070)
			oPrint:Line(nLinha,2790,nLinha+80,2790)
			oPrint:Line(nLinha,3300,nLinha+80,3300)
			oPrint:Say(nLinha+10,2100,'VALOR FRETE (+)',oFont10n)
			oPrint:Say(nLinha+10,2800,'R$',oFont10n)
			oPrint:Say(nLinha+10,3250,TransForm(_nTotFre,'@E 999,999,999,999.99'),oFont10n,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,2070,nLinha,3300)
		EndIf
		
		xVerPag()

		If	( _nTotIcmsRet > 0 )
			oPrint:Line(nLinha,2070,nLinha+80,2070)
			oPrint:Line(nLinha,2790,nLinha+80,2790)
			oPrint:Line(nLinha,3300,nLinha+80,3300)
			oPrint:Say(nLinha+10,2100,'VALOR ICMS RETIDO',oFont10n)
			oPrint:Say(nLinha+10,2800,'R$',oFont10n)
			oPrint:Say(nLinha+10,3250,TransForm(_nTotIcmsRet,'@E 999,999,999,999.99'),oFont10n,,,,1)
			nLinha += 80
			oPrint:Line(nLinha,2070,nLinha,3300)
		EndIf

		xVerPag()

		oPrint:FillRect({nLinha,1620+450,nLinha+80,3300},oBrush)
		oPrint:Line(nLinha,1620+450,nLinha+80,1620+450)
		oPrint:Line(nLinha,2070+450+270,nLinha+80,2070+450+270)
		oPrint:Line(nLinha,3300,nLinha+80,3300)
		oPrint:Say(nLinha+10,1650+450,'VALOR TOTAL ',oFont10n,,CLR_BLACK)		
		oPrint:Say(nLinha+10,2800,'R$',oFont10n)
		oPrint:Say(nLinha+10,3250,TransForm(_nValMerc + _nValIPI - _nValDesc + _nTotAcr	+ _nTotSeg + _nTotFre + _nTotIcmsRet,'@E 999,999,999,999.99'),oFont10n,,CLR_BLACK,,1)
		nLinha += 80
		//xVerPag()
		oPrint:Line(nLinha,2070,nLinha,3300)
		
//		oPrint:Say(nLinha+10,2100,_cMenHor,oFont08)
		IF !EMPTY(SA2->A2_BANCO)
		 	oPrint:Say(nLinha+10,2100,Posicione("SA6",1,xFilial("SA6")+SA2->A2_BANCO,"A6_NREDUZ")+" AG.: "+SA2->A2_AGENCIA+" - "+SA2->A2_UDVAG+"  CC.: "+SA2->A2_NUMCON+" - "+SA2->A2_UDVCTA,oFont10)	
		ENDIF
		nLinha += 70

		xVerPag()

      	oPrint:Say(nLinha,0100,OemToAnsi('Observações:'),oFont10)   
		
		oPrint:Say(nLinha,0500,cObserv1,oFont07)        
		oPrint:Say(nLinha,1600,cObserv5,oFont07)

		nLinha += 40
		//xVerPag()
		
		If	( ! Empty(cObserv2) )
			oPrint:Say(nLinha,0500,cObserv2,oFont07)
			oPrint:Say(nLinha,1600,cObserv6,oFont07)
			nLinha += 40
			xVerPag()
		EndIf	                		
		If	( ! Empty(cObserv3) )
			oPrint:Say(nLinha,0500,cObserv3,oFont07)
			oPrint:Say(nLinha,1600,cObserv7,oFont07)
			xVerPag()
			nLinha += 40
		EndIf			
		If	( ! Empty(cObserv4) )
			oPrint:Say(nLinha,0500,cObserv4,oFont07)
			oPrint:Say(nLinha,1600,cObserv8,oFont07)
			xVerPag()
			nLinha += 40
			xVerPag()
		EndIf
		        
		nLinha += 20
		
		//xVerPag()
		
		oPrint:Line(nLinha,0100,nLinha,3300)
		//nLinha += 10
		//xVerPag()

		TRA->(DbCloseArea())
  
		xRodape()

		oPrint:Preview()

Return


Static Function xCabec()
	
	oPrint:SayBitmap(050,1500+1080,cFileLogo,200,200)     
	     
	oPrint:Say(050,100,ALLTRIM(SM0->M0_NOMECOM)+" - Filial: "+SM0->M0_FILIAL,oFont16) 
	oPrint:Say(050,3140,"Pg.: " + StrZero(_nNrPg,3),oFont10n)
	oPrint:Say(135,100,SM0->M0_ENDCOB,oFont11)
	oPrint:Say(180,100,ALLTRIM(SM0->M0_CIDCOB) +"-"+ALLTRIM(SM0->M0_ESTCOB)+" - "+ALLTRIM(SM0->M0_ENDCOB)+" CEP: "+ALLTRIM(SM0->M0_CEPCOB)+"TEL.: "+ALLTRIM(SM0->M0_TEL),oFont11)
	//oPrint:Say(225,100,AllTrim('www.urbeluz.com.br'),oFont11)
	oPrint:Line(285,100,285,3300)
	oPrint:Say(300,100,"CNPJ: "+Transform(AllTrim(SM0->M0_CGC),"@R 99.999.999/9999-99"),oFont12) 
	oPrint:Say(300,2750,"INSC.EST.: "+SM0->M0_INSC,oFont12)
      
	oPrint:Say(0370,2750,OemToAnsi('PEDIDO NR: '),oFont13) 
	oPrint:Say(0370,3120,OemToAnsi(SC7->C7_NUM),oFont13)
	oPrint:Say(0450,2750,OemToAnsi('SOLIC.NR: '),oFont13) 
	oPrint:Say(0450,3120,OemToAnsi(SC7->C7_NUMSC),oFont13)
	oPrint:Say(0520,2750,OemToAnsi('CONTATO : '),oFont13) 
	oPrint:Say(0520,3120,OemToAnsi(SC7->C7_CONTATO),oFont13)
Return


Static Function xRodape()
                     
    Local _nLn 		:= 2045      
    
    If _lSub == .T. 
		oPrint:FillRect({_nLn,2070,_nLn+80,3300},oBrush)
		oPrint:Line(_nLn,2070,_nLn+80,2070)
		oPrint:Line(_nLn,2790,_nLn+80,2790)
		oPrint:Line(_nLn,3300,_nLn+80,3300)
		oPrint:Say(_nLn+10,2100,'SUB TOTAL ',oFont10n,,CLR_BLACK)		
		oPrint:Say(_nLn+10,2800,'R$',oFont10n)
		oPrint:Say(_nLn+10,3250,TransForm(_nValMerc,'@E 999,999,999,999.99'),oFont10n,,CLR_BLACK,,1)
		_nLn += 50
		oPrint:Line(_nLn,2070,_nLn,3300)
		oPrint:Say(_nLn+10,2100,SUBSTR(_cMenHor,1,146),oFont08)
		_nLn += 50
		oPrint:Say(_nLn+10,2100,SUBSTR(_cMenHor,147,150),oFont08)
		_nLn += 50
		oPrint:Say(_nLn+10,2100,SUBSTR(_cMenHor,197,150),oFont08)
    EndIf              
                             
	//oPrint:Line(2400,0100,2400,3300)
    oPrint:Say(2220,0100,SUBSTR(_cMenHor,1,146),oFont08)
    oPrint:Say(2270,0100,SUBSTR(_cMenHor,147,150),oFont08)
    oPrint:Say(2340,0100,SUBSTR(_cMenHor,297,150),oFont08)
	//oPrint:Line(2500,0100,2500,3300)

Return


Static Function xVerPag()

	If	( nLinha >= 3000 - 1000)
                     
		_nNrPg ++
		
		If	( ! lFlag )
			xRodape()
			oPrint:EndPage()
			nLinha:= 500 - 50
		Else
			nLinha:= 700 - 50
		EndIf

		oPrint:StartPage()
		xCabec()

		lPrintDesTab := .t.

	EndIf	

Return


Static Function AjustaSX1(cPerg)

	Local nX
	Local aRegs   := {}
	//Local _sAlias := Alias()

	aAdd(aRegs,{cPerg,'01','Numero do Pedido   ?',' ?',' ?','mv_ch1','C', 6,0,0,'G','','mv_par01','','','','','',''})
	aAdd(aRegs,{cPerg,'02','Imprime precos     ?',' ?',' ?','mv_ch2','N', 1,0,1,'C','','mv_par02','Nao','Sim','','','',''})
	aAdd(aRegs,{cPerg,'03','Titulo Relatorio   ?',' ?',' ?','mv_ch3','N', 1,0,1,'C','','mv_par03','Cotacao','Pedido','','','',''})

	DbSelectArea('SX1')
	SX1->(DbSetOrder(1))

	For nX:=1 to Len(aRegs)
		If	( ! SX1->(DbSeek(aRegs[nx][01]+aRegs[nx][02])) )
			If	RecLock('SX1',.T.)
				Replace SX1->X1_GRUPO  		With aRegs[nx][01]
				Replace SX1->X1_ORDEM   	With aRegs[nx][02]
				Replace SX1->X1_PERGUNTE	With aRegs[nx][03]
				Replace SX1->X1_PERSPA		With aRegs[nx][04]
				Replace SX1->X1_PERENG		With aRegs[nx][05]
				Replace SX1->X1_VARIAVL		With aRegs[nx][06]
				Replace SX1->X1_TIPO		With aRegs[nx][07]
				Replace SX1->X1_TAMANHO		With aRegs[nx][08]
				Replace SX1->X1_DECIMAL		With aRegs[nx][09]
				Replace SX1->X1_PRESEL		With aRegs[nx][10]
				Replace SX1->X1_GSC			With aRegs[nx][11]
				Replace SX1->X1_VALID		With aRegs[nx][12]
				Replace SX1->X1_VAR01		With aRegs[nx][13]
				Replace SX1->X1_DEF01		With aRegs[nx][14]
				Replace SX1->X1_DEF02		With aRegs[nx][15]
				Replace SX1->X1_DEF03		With aRegs[nx][16]
				Replace SX1->X1_DEF04		With aRegs[nx][17]
				Replace SX1->X1_DEF05		With aRegs[nx][18]
				Replace SX1->X1_F3   		With aRegs[nx][19]
				SX1->(MsUnlock())
			Else
				Help('',1,'REGNOIS')
			EndIf	
		Endif
	Next nX

Return

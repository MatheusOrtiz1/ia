#Include "FWMVCDef.ch"

/*╠╠зддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    CT102BUT   Ё Aut.  ЁEverton	            Ё Data Ё20/08/2023Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o ЁAdiciona menu da tela de LanГamento contabil automatico     Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁMСdulo: CONASA  			Rotina: CT102BUT                              Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢*/

User Function CT102BUT()
Local AAREA     := GETAREA()
Local aBotao  := {}

aAdd(aBotao, {'WF AprovaГЦo Lcto.',"U_WFCT2(2)",   0 , 3    })
aAdd(aBotao, {'Libera LanГamento Manual',"U_LIBCT2M()",   0 , 3    })

RestArea(aArea)


Return(aBotao)


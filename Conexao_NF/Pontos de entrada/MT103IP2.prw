#Include "Protheus.ch"

/*/{Protheus.doc} MT103IP2
// Ponto de entrada utilizado pelo importador da ConexãoNF-e para limpar a variável __cInterNet e forçar 
a apresentação dos alertas customizados durante a importação.
@author ConexãoNF-e
@since 02/03/2022
@version 1.0
@return Nil, Nulo
@see (https://atendimento.conexaonfe.com.br/kb/)
/*/
User Function MT103IP2()
    
    // Ponto de chamada ConexãoNF-e sempre como primeira instrução.
    U_GTPE007() 

    //If
	//	Regra existente
	//	[...]
	//EndIf
    
Return Nil

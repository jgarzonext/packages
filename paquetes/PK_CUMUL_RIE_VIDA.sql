--------------------------------------------------------
--  DDL for Package PK_CUMUL_RIE_VIDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_CUMUL_RIE_VIDA" IS
  TYPE t_mensajes IS RECORD (
  	   CONTR    NUMBER(1), -- 0=O.K.,1=Sob. Limite,2=Error Formula,3=Error Funcion
  	   TIPO     NUMBER(1), -- 0=Nivel Contrato 1=Nivel Garantía(capital)
  	   TOTAL    NUMBER,
  	   TEXTO    VARCHAR2(60),
  	   DOCUM    VARCHAR2(3));
  TYPE t_mensa IS TABLE OF t_mensajes INDEX BY BINARY_INTEGER;
  mensa t_mensa;
  errs  NUMBER := 0;
  FUNCTION buscar_cumulo (psproduc IN NUMBER, -- Clave Producto
                        pfecefe  IN DATE,     -- Fecha efecto
						pcont    IN NUMBER,
						parms_transitorios IN OUT Pac_Parm_Tarifas.parms_transitorios_TabTyb)
    RETURN NUMBER; --> (> 0)=Retorna nro. de mensajes, (< 0)=Error.
  FUNCTION busca_cum_gar(psproduc IN NUMBER, -- Clave Producto
                         pfecefe  IN DATE,   -- Fecha efecto
						pcont    IN  NUMBER,
						parms_transitorios IN OUT Pac_Parm_Tarifas.parms_transitorios_TabTyb)
    RETURN NUMBER; --> (> 0)=Retorna nro. de mensajes, (< 0)=Error.
  FUNCTION tratar_cumulos(pccumulo    IN NUMBER, -- Clave del Cumulo
           				  pfecefe     IN DATE,   -- Fecha Efecto
						  pnivel      IN NUMBER, -- 0-Contratos 1-Capitales 2-Garantias
						  pcont       IN  NUMBER,
						  parms_transitorios IN OUT Pac_Parm_Tarifas.parms_transitorios_TABTYb)
    RETURN NUMBER;  --> (0)=o.k., (< 0)=Error.
  FUNCTION buscar_formula(pclave    IN NUMBER,   -- Clave Formula
                        pformula OUT VARCHAR2,   -- Formula
                        pcodigo  OUT VARCHAR2)   -- Codigo
    RETURN NUMBER;
  FUNCTION ver_mensajes(nerr IN NUMBER)
   RETURN VARCHAR2;
  PROCEDURE BORRA_MENSAJES;
END Pk_Cumul_Rie_Vida;

 
 

/

  GRANT EXECUTE ON "AXIS"."PK_CUMUL_RIE_VIDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_CUMUL_RIE_VIDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_CUMUL_RIE_VIDA" TO "PROGRAMADORESCSI";

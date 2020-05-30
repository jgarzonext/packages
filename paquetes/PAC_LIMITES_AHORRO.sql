--------------------------------------------------------
--  DDL for Package PAC_LIMITES_AHORRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_LIMITES_AHORRO" AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:      PAC_LIMITES_AHORRO
   PROPÓSITO:   Funciones para calcular los limites de aportaciones para PIAS

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0          xxx          xxx           1. Creación del package.
   2.0        08/05/2009     APD           2. Bug 9922: se añade el parametro porigen a las
                                              funciones:
                                              . ff_calcula_importe
                                              . ff_importe_por_aportar_persona
                                              . f_aportaciones_limite
   3.0       18/02/2010      RSC           4 0017707: CEM800 - 2010: Modelo 345
******************************************************************************/

   -- RSC 30/01/2008
   -- Form aladm411.fmb --> Aport. Max: Limite total
   FUNCTION ff_iaporttotal(pctiplim IN NUMBER, pdatainici IN DATE)
      RETURN NUMBER;

   -- RSC 30/01/2008
   -- Form aladm411.fmb --> Aport. Max: Limite anual
   FUNCTION ff_iaportanual(pctiplim IN NUMBER, pdatainici IN DATE)
      RETURN NUMBER;

   -- RSC 30/01/2008
   -- Form aladm411.fmb --> Aport. acumuladas
   FUNCTION ff_calcula_importe(
      pctiplim IN NUMBER,
      psperson IN NUMBER,
      pany IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 2,   -- Bug 9922 - APD - 08/05/2009 - se añade el parametro porigen
      pmodo IN NUMBER DEFAULT 1)   -- Bug 17707 - RSC - 18/02/2010 - CEM800 - 2010: Modelo 345
      RETURN NUMBER;

   /**************************************************************************************************
     Función que devuelve el capital o importe en función de los limites establecidos y los importes
     satisfechos por la persona en pólizas del ramo. (Función para VALIDA_COMU.f_valida_capital_persona)
         -- Para alta de pólizas:
         --    PUB_CONTRATA_AHO.f_valida_garantias_aho -->
         --    VALIDA_COMU.f_valida_capital_persona -->
         --    PAC_LIMITES_AHORRO.ff_importe_por_aportar_persona
   **************************************************************************************************/
   FUNCTION ff_importe_por_aportar_persona(
      pany IN NUMBER,
      pctiplim IN NUMBER,
      psperson IN NUMBER,
      pfefecto IN DATE,
      porigen IN NUMBER DEFAULT 2)   -- Bug 9922 - APD - 08/05/2009 - se añade el parametro porigen
      RETURN NUMBER;

   -- RSC 31/01/2008 (En nuestro caso este tipo se desarrolla para el PIAS)
   TYPE rt_datos_pias IS RECORD(
      tiplim         VARCHAR2(100),   -- Descripcción del límite (tatribu del Valor Fijo 280).
      nseguros       NUMBER,   -- Numero de seguros PIAS de la persona o persona del seguro
      aportanual     NUMBER,   -- Suma de aportaciones realizadas en pólizas PIAS del año
      aporttotal     NUMBER,   -- Suma de aportaciones realizadas en pólizas PIAS en su totalidad
      imaxanual      NUMBER,   -- Límite máximo permitido legalmente de aportación anual en pólizas PIAS
      imaxtotal      NUMBER   -- Límite máximo permitido legalmente de aportación a pólizas PIAS en su totalidad
   );

   -- RSC 31/01/2008
   TYPE ct_datos_pias IS REF CURSOR
      RETURN rt_datos_pias;

   /***********************************************************************************
    -- RSC 31/01/2008 Consulta de pólizas TF (Cúmulos de pólizas PIAS).
    -- Información de sálida:
            --> Numero de pólizas PIAS de la persona o la persona del seguro
            -->
   ***********************************************************************************/
   FUNCTION f_aportaciones_limite(
      pctiplim IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      psperson IN per_personas.sperson%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE,
      porigen IN NUMBER DEFAULT 2)   -- Bug 9922 - APD - 08/05/2009 - se añade el parametro porigen
      RETURN ct_datos_pias;
END pac_limites_ahorro;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_LIMITES_AHORRO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LIMITES_AHORRO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LIMITES_AHORRO" TO "PROGRAMADORESCSI";

--------------------------------------------------------
--  DDL for Package PAC_REF_SIMULA_AHO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_REF_SIMULA_AHO" AUTHID CURRENT_USER IS
/******************************************************************************
  Package encargado de las simulaciones de pólizas de ahorro

******************************************************************************/
   FUNCTION f_valida_prima_aho(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      picapital IN NUMBER,
      pcforpag IN NUMBER,
      psperson IN NUMBER,
      pcpais IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      coderror OUT NUMBER,
      msgerror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_valida_poliza_renova(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_valida_duracion_renova(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pndurper IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_simulacion_pu(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      pnombre1 IN VARCHAR2,
      ptapelli1 IN VARCHAR2,
      pfnacimi1 IN DATE,
      psexo1 IN NUMBER,
      pcpais1 IN NUMBER,
      psperson2 IN NUMBER,
      pnombre2 IN VARCHAR2,
      ptapelli2 IN VARCHAR2,
      pfnacimi2 IN DATE,
      psexo2 IN NUMBER,
      pcpais2 IN NUMBER,
      pcidioma IN NUMBER DEFAULT 1,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      piprima IN NUMBER,
      pndurper IN NUMBER,
      pfvencim IN DATE,
      ppinttec IN NUMBER,
      pcagente IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER)
      RETURN ob_resp_simula_pu;

   --
   -- Ref 2253. : F_SIMULACION_PP.
   --
   --   La función retornará  un objeto de tipo ob_resp_simula_pp con los datos de los valores garantizados y el error
   --   (si se ha producido)
   --
   --  Paràmetres
   --    ptipo: 1 .- Alta
   --           2.- Revisión
   --           Si ptipo =2 (revisión) los parámetros pnpoliza y pncertif deben venir informados
   --    psProduc                Producte
   --    pcAgente
   --    pcIdioma_user           Idioma de la pantalla
   --    pPersona1               Estructura amb les dades de la persona 1
   --      sPerson                 Identificador de l'assegurat. Pot ser a NULL per la simulació.
   --      tNombre                 Nom de l'assegurat
   --      tApellido               Cognom de l'assegurat
   --      fNacimiento             Data de Naixement de l'assegurat
   --      cSexo                   Sexe de l'assegurat:     1 - Home,  2- Dona
   --      cPais                   Codi de l'estat de residència de l'assegurat
   --      cIdioma                 Idioma per la impressió de la simulació.
   --    pPersona2               Estructura amb les dades de la persona 2
   --      sPerson                 Identificador de l'assegurat. Pot ser a NULL per la simulació.
   --      tNombre                 Nom de l'assegurat
   --      tApellido               Cognom de l'assegurat
   --      fNacimiento             Data de Naixement de l'assegurat
   --      cSexo                   Sexe de l'assegurat:     1 - Home,  2- Dona
   --      cPais                   Codi de l'estat de residència de l'assegurat
   --      cIdioma                 No utilitzat.
   --    pfVencim                Data de la jubilació de la Persona 1
   --    piPrima                 Import de la prima inicial. Mínim 30€.
   --    piPeriodico             Aportació periòdica. Mínim 30€.
   --    ppInteres               Percentatge d'interès
   --    ppRevalorizacion        Percentatge de revalorització
   --    ppInteres_Pres          Interès de les prestacions
   --    ppRevalorizacion_Pres   Percentatge de revalorització de les prestacions. A NULL per PE i PPA
   --    ppReversion_Pres        Percentatge de reversió a les prestacions. A NULL per PE i PPA
   --    pAnosRenta_Pres
   --

   -- Funció per ser cridada des del Java
   FUNCTION f_simulacion_pp(
      psproduc IN NUMBER,
      pcagente IN NUMBER,
      pcidioma_user IN NUMBER DEFAULT 1,
      -- Persona 1
      psperson1 IN NUMBER,
      ptnombre1 IN VARCHAR2,
      ptapellido1 IN VARCHAR2,
      pfnacimiento1 IN DATE,
      pcsexo1 IN NUMBER,
      pcpais1 IN NUMBER,
      pcidioma IN NUMBER,
      -- Persona 2
      psperson2 IN NUMBER,
      ptnombre2 IN VARCHAR2,
      ptapellido2 IN VARCHAR2,
      pfnacimiento2 IN VARCHAR2,
      pcsexo2 IN NUMBER,
      pcpais2 IN NUMBER,
      -- Otros
      pfvencim IN DATE,
      piprima IN NUMBER,
      piperiodico IN NUMBER,
      ppinteres IN NUMBER,
      pprevalorizacion IN NUMBER,
      ppinteres_pres IN NUMBER,
      pprevalorizacion_pres IN NUMBER DEFAULT NULL,
      ppreversion_pres IN NUMBER DEFAULT NULL,
      panosrenta_pres IN NUMBER DEFAULT NULL)
      RETURN ob_resp_simula_pp;
END pac_ref_simula_aho;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_AHO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_AHO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SIMULA_AHO" TO "PROGRAMADORESCSI";

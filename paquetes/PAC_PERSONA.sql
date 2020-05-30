
  CREATE OR REPLACE PACKAGE "PAC_PERSONA" IS
/******************************************************************************
   NOMBRE:       PAC_PERSONA
   PROPÓSITO: Funciones para gestionar personas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------  ------------------------------------
   1.0        --           XXX          1. Creación del package.
   2.0        18/05/2009   JTS          2. 10074: Modificaciones en el Mantenimiento de Personas
   3.0        09/06/2009   JTS          3. 10371: APR - tipo de empresa
   4.0        21/12/2009   AMC          4. Bug 10684: Se crea la función f_get_idioma_age
   5.0        26/03/2010   AMC          5. 0012716: CEM - PPA - Cálculo de IRPF en prestaciones
   6.0        11/05/2010   DRA          6. 0014307: AGA005 - PERSONES: Parametrització inicial del mòdul
   7.0        27/07/2011   ICV          7. 0018941: LCOL_P001 - PER - Personas relacionadas. Representante legal
   8.0        26/09/2011   MDS          8. 0018943  Modulo SARLAFT en el mantenimiento de personas
   9.0        04/10/2011   MDS          9. 0018947: LCOL_P001 - PER - Posición global
  10.0        08/11/2011   JGR         10. 0019985  LCOL_A001-Control de las matriculas (prenotificaciones)
  11.0        23/11/2011   APD         11. 0020126: LCOL_P001 - PER - Documentación en personas
  12.0        03/01/2012   APD         12. 0020790: LCOL - UAT - PER - Arreglar errores de personas de entorno UAT
  13.0        13/02/2012   JMP         13. 21270/107049: LCOL898 - Interfase persones. Tractament errors crida a PAC_CON.F_ALTA_PERSONA.
  14.0        29/02/2012   ETM         14. 0021406: MDP - PER - Añadir el nombre en la tabla contactos
  15.0        11/07/2012   ETM         15. 0022263: LCOL_P001 - PER - Informaci?n relacionado con documentos identificativos.
  16.0        24/07/2012   ETM         16. 0022642: MDP - PER - Posición global. Inquilinos, avalistas y gestor de cobro
  17.0        24/07/2012   ETM         17. 0022642: MDP - PER - Posición global. Inquilinos, avalistas y gestor de cobro
  18.0        31/01/2013   JDS         18. 0025849: LCOL - PER - Posición global de personas : conductores
  19.0        11/02/2013   DCT         19. 0026057/0137564:LCOL - PER - Atuorizacion de contactos - Relación entre contactos y direcciones
  20.0        25/02/2013   NMM         20. 24497: POS101 - Configuraci?n Rentas Vitalicias
  21.0        05/03/2013   MMS         21. 0024764: (POSDE300)-Desarrollo-GAPS Personas-Id 99 - Funcionario - Creacion . Reodenamos la lista de f_get_parpersona, quitamos la funcion f_get_conductores y la ponemos en PAC_MD_PERSONAS
  22.0        08/07/2013   RCL         22. 0025599: LCOL - PER - Revision incidencias qtracker y Releases
  23.0        10/10/2013   JMG         23. 0155391/0155391: POS - PER - Anotación en la agenda de las pólizas cuando se modifique los datos de un tercero.
  24.0        03/04/2014   FAL         24. 0030525: INT030-Prueba de concepto CONFIANZA
  25.0        01/07/2014   GGR         25. 27314/178602: Inclusion funcion comprobacion persona gubernamental
  26.0        14/10/2014   MMS         26. 0031135: Montar Entorno Colmena en VAL
  27.0        17/03/2015   KJSC        27. 34989/200761 Modificacion de la funcion f_set_nacionalidad.
  28.0        23/06/2016   ERH         30. CONF-52 Modificación de la función f_set_persona_rel se adiciona al final el parametro • PTLIMIT VARCHAR2
  29.0        23/11/2018   ACL         29. CP0727M_SYS_PERS_Val Se agrega en la función f_set_datsarlatf el parámetro pcorigenfon.
  30.0        18/12/2018   ACL         30. CP0416M_SYS_PERS Se agrega la función f_get_persona_sarlaf.
  31.0        07/01/2019   SWAPNIL     31. Cambios para solicitudes múltiples
  32.0        30/01/2019   WAJ         32.Se adiciona funcion para eliminar los indicadores de una persona
  33.0        12/02/2019   AP          34. TCS-9: Se adiciona campos en la funcion f_set_datsarlatf para clausulas.
  34.0        27/02/2019   AABC        32. IAXIS-2091 Convivencia Pagador Alternativo TCS-1560
  35.0        01/04/2019   DFRP        35. IAXIS-3287:FCC (Formulario de Conocimiento de Cliente).
  36.0 		  27/06/2019   KK		   36. CAMBIOS De IAXIS-4538
  37.0		 18/07/2019	  PK		37. Added function for IAXIS-4149 - Modificación Cuentas Bancarias
   ******************************************************************************/
   PROCEDURE borrar_tablas_estper(
      psperson IN estper_personas.sperson%TYPE,
      psimul IN NUMBER DEFAULT NULL);

   PROCEDURE borrar_tablas_estpereal(
      pspereal IN per_personas.sperson%TYPE,
      psseguro IN estseguros.sseguro%TYPE);

   PROCEDURE borrar_tablas_estper_seg(psseguro IN estseguros.sseguro%TYPE);

   PROCEDURE traspaso_tablas_estper(
      psperson IN estper_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pcempres IN empresas.cempres%TYPE   --BUG8644-17032009-XVM
-- bug 7873 le quitamos el default para que llegue desde la capa md     DEFAULT NULL -- DRA 29-9-08: bug mantis 7567
   );

   PROCEDURE traspaso_tablas_per(
      psperson IN per_personas.sperson%TYPE,
      pficticia_sperson OUT estper_personas.sperson%TYPE,
      psseguro IN seguros.sseguro%TYPE DEFAULT NULL,
      pcagente IN agentes.cagente%TYPE DEFAULT NULL);

   -- si el usuario es de central traspasa todos los detalles si no solo el suyo.
   FUNCTION f_shisper(psperson IN hisper_personas.sperson%TYPE)
      RETURN NUMBER;

   FUNCTION f_sperson_spereal(psperson IN estper_personas.sperson%TYPE)
      RETURN NUMBER;

   FUNCTION f_spereal_sperson(
      psperson IN estper_personas.spereal%TYPE,
      psseguro IN estseguros.sseguro%TYPE)
      RETURN NUMBER;

   FUNCTION f_shisdet(
      psperson IN hisper_detper.sperson%TYPE,
      pcagente IN hisper_detper.cagente%TYPE)
      RETURN NUMBER;

   FUNCTION f_shiscon(
      psperson IN hisper_contactos.sperson%TYPE,
      pcmodcon IN hisper_contactos.cmodcon%TYPE)
      RETURN NUMBER;

--------------------------------------------  --------------------------------------------
-- DIRECCIONES ------------------------------   --------------------------------------------
--------------------------------------------  --------------------------------------------
   FUNCTION f_set_direccion(
      psperson IN estper_direcciones.sperson%TYPE,
      pcagente IN estper_direcciones.cagente%TYPE,
      pcdomici IN OUT estper_direcciones.cdomici%TYPE,
      pctipdir IN estper_direcciones.ctipdir%TYPE,
      pcsiglas IN estper_direcciones.csiglas%TYPE,
      ptnomvia IN estper_direcciones.tnomvia%TYPE,
      pnnumvia IN estper_direcciones.nnumvia%TYPE,
      ptcomple IN estper_direcciones.tcomple%TYPE,
      ptdomici IN estper_direcciones.tdomici%TYPE,
      pcpostal IN estper_direcciones.cpostal%TYPE,
      pcpoblac IN estper_direcciones.cpoblac%TYPE,
      pcprovin IN estper_direcciones.cprovin%TYPE,
      pcusuari IN estper_direcciones.cusuari%TYPE,
      pfmovimi IN estper_direcciones.fmovimi%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      perrores OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      -- Bug 18940/92686 - 27/09/2011 - AMC
      pcviavp IN estper_direcciones.cviavp%TYPE,
      pclitvp IN estper_direcciones.clitvp%TYPE,
      pcbisvp IN estper_direcciones.cbisvp%TYPE,
      pcorvp IN estper_direcciones.corvp%TYPE,
      pnviaadco IN estper_direcciones.nviaadco%TYPE,
      pclitco IN estper_direcciones.clitco%TYPE,
      pcorco IN estper_direcciones.corco%TYPE,
      pnplacaco IN estper_direcciones.nplacaco%TYPE,
      pcor2co IN estper_direcciones.cor2co%TYPE,
      pcdet1ia IN estper_direcciones.cdet1ia%TYPE,
      ptnum1ia IN estper_direcciones.tnum1ia%TYPE,
      pcdet2ia IN estper_direcciones.cdet2ia%TYPE,
      ptnum2ia IN estper_direcciones.tnum2ia%TYPE,
      pcdet3ia IN estper_direcciones.cdet3ia%TYPE,
      ptnum3ia IN estper_direcciones.tnum3ia%TYPE,
      -- Fi Bug 18940/92686 - 27/09/2011 - AMC
      plocalidad IN estper_direcciones.localidad%TYPE,
                                                     -- Bug 24780/130907 - 05/12/2012 - AMC
      ptalias IN estper_direcciones.talias%TYPE      -- BUG CONF-441 - 14/12/2016 - JAEG
   )
      RETURN NUMBER;

   -- NO UTILIZAR LA SIGUIENTE FUNCIÓN ---- NO UTILIZAR ---
   PROCEDURE p_set_direccion(
      psperson IN estper_direcciones.sperson%TYPE,
      pcagente IN estper_direcciones.cagente%TYPE,
      pcdomici IN OUT estper_direcciones.cdomici%TYPE,
      pctipdir IN estper_direcciones.ctipdir%TYPE,
      pcsiglas IN estper_direcciones.csiglas%TYPE,
      ptnomvia IN estper_direcciones.tnomvia%TYPE,
      pnnumvia IN estper_direcciones.nnumvia%TYPE,
      ptcomple IN estper_direcciones.tcomple%TYPE,
      ptdomici IN estper_direcciones.tdomici%TYPE,
      pcpostal IN estper_direcciones.cpostal%TYPE,
      pcpoblac IN estper_direcciones.cpoblac%TYPE,
      pcprovin IN estper_direcciones.cprovin%TYPE,
      pcusuari IN estper_direcciones.cusuari%TYPE,
      pfmovimi IN estper_direcciones.fmovimi%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      perrores OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      -- Bug 18940/92686 - 27/09/2011 - AMC
      pcviavp IN estper_direcciones.cviavp%TYPE,
      pclitvp IN estper_direcciones.clitvp%TYPE,
      pcbisvp IN estper_direcciones.cbisvp%TYPE,
      pcorvp IN estper_direcciones.corvp%TYPE,
      pnviaadco IN estper_direcciones.nviaadco%TYPE,
      pclitco IN estper_direcciones.clitco%TYPE,
      pcorco IN estper_direcciones.corco%TYPE,
      pnplacaco IN estper_direcciones.nplacaco%TYPE,
      pcor2co IN estper_direcciones.cor2co%TYPE,
      pcdet1ia IN estper_direcciones.cdet1ia%TYPE,
      ptnum1ia IN estper_direcciones.tnum1ia%TYPE,
      pcdet2ia IN estper_direcciones.cdet2ia%TYPE,
      ptnum2ia IN estper_direcciones.tnum2ia%TYPE,
      pcdet3ia IN estper_direcciones.cdet3ia%TYPE,
      ptnum3ia IN estper_direcciones.tnum3ia%TYPE,
      -- Fi Bug 18940/92686 - 27/09/2011 - AMC
      plocalidad IN estper_direcciones.localidad%TYPE,
      -- Bug 24780/130907 - 05/12/2012 - AMC
      pfdefecto IN estper_direcciones.fdefecto%TYPE);

   PROCEDURE p_del_direccion(
      psperson IN estper_direcciones.sperson%TYPE,
      pcdomici IN estper_direcciones.cdomici%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      errores OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST');

   FUNCTION f_valida_codigosdireccion(
      pcpais IN NUMBER,
      pcpoblac IN estper_direcciones.cpoblac%TYPE,
      pcprovin IN estper_direcciones.cprovin%TYPE,
      pcpostal IN estper_direcciones.cpostal%TYPE)
      RETURN NUMBER;

   PROCEDURE p_del_contacto(
      psperson IN estper_contactos.sperson%TYPE,
      psmodcon IN estper_contactos.cmodcon%TYPE,
      errores OUT t_ob_error,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST');

   PROCEDURE p_del_nacionalidad(
      psperson IN estper_nacionalidades.sperson%TYPE,
      pcpais IN estper_nacionalidades.cpais%TYPE,
      pcagente IN estper_nacionalidades.cagente%TYPE,
      errores OUT t_ob_error,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST');

   FUNCTION f_tdomici(
      pcsiglas IN per_direcciones.csiglas%TYPE,
      ptnomvia IN per_direcciones.tnomvia%TYPE,
      pnnumvia IN per_direcciones.nnumvia%TYPE,
      ptcomple IN per_direcciones.tcomple%TYPE,
      -- Bug 18940/92686 - 27/09/2011 - AMC
      pcviavp IN per_direcciones.cviavp%TYPE DEFAULT NULL,
      pclitvp IN per_direcciones.clitvp%TYPE DEFAULT NULL,
      pcbisvp IN per_direcciones.cbisvp%TYPE DEFAULT NULL,
      pcorvp IN per_direcciones.corvp%TYPE DEFAULT NULL,
      pnviaadco IN per_direcciones.nviaadco%TYPE DEFAULT NULL,
      pclitco IN per_direcciones.clitco%TYPE DEFAULT NULL,
      pcorco IN per_direcciones.corco%TYPE DEFAULT NULL,
      pnplacaco IN per_direcciones.nplacaco%TYPE DEFAULT NULL,
      pcor2co IN per_direcciones.cor2co%TYPE DEFAULT NULL,
      pcdet1ia IN per_direcciones.cdet1ia%TYPE DEFAULT NULL,
      ptnum1ia IN per_direcciones.tnum1ia%TYPE DEFAULT NULL,
      pcdet2ia IN per_direcciones.cdet2ia%TYPE DEFAULT NULL,
      ptnum2ia IN per_direcciones.tnum2ia%TYPE DEFAULT NULL,
      pcdet3ia IN per_direcciones.cdet3ia%TYPE DEFAULT NULL,
      ptnum3ia IN per_direcciones.tnum3ia%TYPE DEFAULT NULL,
      -- Fi Bug 18940/92686 - 27/09/2011 - AMC
      plocalidad IN per_direcciones.localidad%TYPE
            DEFAULT NULL   -- Bug 24780/130907 - 05/12/2012 - AMC
                        )
      RETURN VARCHAR2;

   FUNCTION f_sperson
      RETURN NUMBER;

   FUNCTION f_estsperson
      RETURN NUMBER;

   FUNCTION f_shisdir(
      psperson IN hisper_direcciones.sperson%TYPE,
      pcdomici IN hisper_direcciones.cdomici%TYPE)
      RETURN NUMBER;

   FUNCTION f_shisvin(psperson IN hisper_personas.sperson%TYPE)
      RETURN NUMBER;

--------------------------------------------  --------------------------------------------
-- LOPD  ------------------------------   --------------------------------------------
--------------------------------------------  --------------------------------------------
   FUNCTION f_shislopd(psperson IN hisper_personas.sperson%TYPE)
      RETURN NUMBER;

   FUNCTION f_nordenlopd(psperson IN per_lopd.sperson%TYPE)
      RETURN NUMBER;

--------------------------------------------  --------------------------------------------
-- ISO  ------------------------------   --------------------------------------------
--------------------------------------------  --------------------------------------------
   FUNCTION f_shisirpf(psperson IN hisper_personas.sperson%TYPE)
      RETURN NUMBER;
/***************************************************************************
   Procedure p_paga_oz_iax procedimiento Oziris Iaxis pagador alternativo
     sperson  in number   numero de persona principal
     sperson_rel in number Numero del pagador alternativo
     IAXIS-2091 TCS 1560 Convivencia pagador Alternativo 
  ******************************************************************************/
   PROCEDURE p_paga_oz_iax (
      psperson     IN per_pagador_alt.sperson%TYPE,
      psperson_rel IN per_pagador_alt.sperson_rel%TYPE) ;
  --      
   PROCEDURE p_del_ccc(
      psperson IN estper_ccc.sperson%TYPE,
      pcnordban IN estper_ccc.cnordban%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      errores OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST');

   --Función que retorna el norden máximo para esa persona.
   FUNCTION f_shisccc(psperson IN hisper_ccc.sperson%TYPE)
      RETURN NUMBER;

   FUNCTION f_existe_persona(
      pcempres IN empresas.cempres%TYPE,
      pnnumide IN per_personas.nnumide%TYPE,
      pcsexper IN per_personas.csexper%TYPE,
      pfnacimi IN per_personas.fnacimi%TYPE,
      psperson_new OUT per_personas.sperson%TYPE,
      psnip IN per_personas.snip%TYPE,
      pspereal IN per_personas.sperson%TYPE DEFAULT NULL,
      pctipide IN per_personas.ctipide%TYPE DEFAULT NULL)   -- t.9318
      RETURN NUMBER;

   PROCEDURE p_validapersona(
      psperson IN per_personas.sperson%TYPE,
      pidioma_usu IN NUMBER,   --¿ Idioma de los errores
      ctipper IN NUMBER,   --¿ tipo de persona (física o jurídica)
      ctipide IN NUMBER,   --¿ tipo de identificación de persona
      nnumide IN VARCHAR2,
      --- Número identificativo de la persona.
      csexper IN NUMBER,   -- sexo de la pesona.
      fnacimi IN DATE,   -- Fecha de nacimiento de la persona
      psnip IN VARCHAR2,   -- snip
      cestper IN NUMBER,   --¿ estado
      fjubila IN DATE,   --¿
      cmutualista IN NUMBER,   --¿
      fdefunc IN DATE,   --¿
      nordide IN NUMBER,   --¿
      cidioma IN NUMBER,   --¿Código idioma
      tapelli1 IN VARCHAR2,   --¿   Primer apellido
      tapelli2 IN VARCHAR2,   --¿   Segundo apellido
      tnombre IN VARCHAR2,   --¿   Nombre de la persona
      tsiglas IN VARCHAR2,   --¿   Siglas persona jurídica
      cprofes IN VARCHAR2,   --¿ Código profesión
      cestciv IN NUMBER,   --¿Código estado civil. VALOR FIJO = 12
      cpais IN NUMBER,   --¿   Código país de residencia
      ptablas IN VARCHAR2,
      pcempres IN empresas.cempres%TYPE,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      errores IN OUT t_ob_error,
      pcocupacion IN VARCHAR2   -- Bug 25456/133727 - 16/01/2013 - AMC
                             );

   FUNCTION f_set_persona(
      pidioma_usu IN NUMBER,   --¿ Idioma de los errores
      psseguro IN seguros.sseguro%TYPE,
      psperson IN OUT NUMBER,
      pspereal IN NUMBER,
      pcagente IN OUT NUMBER,
      pctipper IN NUMBER,   --¿ tipo de persona (física o jurídica)
      pctipide IN NUMBER,   --¿ tipo de identificación de persona
      pnnumide IN VARCHAR2,
      --- Número identificativo de la persona.
      pcsexper IN NUMBER,   -- sexo de la pesona.
      pfnacimi IN DATE,   -- Fecha de nacimiento de la persona
      psnip IN VARCHAR2,   -- snip
      pcestper IN NUMBER,   --¿ estado
      pfjubila IN DATE,   --¿
      pcmutualista IN NUMBER,   --¿
      pfdefunc IN DATE,   --¿
      pnordide IN NUMBER,   --¿
      pcidioma IN NUMBER,   --¿Código idioma
      ptapelli1 IN VARCHAR2,   --¿    Primer apellido
      ptapelli2 IN VARCHAR2,   --¿    Segundo apellido
      ptnombre IN VARCHAR2,   --¿    Nombre de la persona
      ptsiglas IN VARCHAR2,   --¿    Siglas persona jurídica
      pcprofes IN VARCHAR2,   --¿    Código profesión
      pcestciv IN NUMBER,   --¿Código estado civil VALOR FIJO = 12
      pcpais IN NUMBER,   -- pais
      pcempres IN empresas.cempres%TYPE,
      ptablas IN VARCHAR2,
      pswpubli IN NUMBER DEFAULT 0,
      ptnombre1 IN VARCHAR2,
      ptnombre2 IN VARCHAR2,
      pswrut IN NUMBER DEFAULT 0,
      pcocupacion IN VARCHAR2 DEFAULT NULL   -- Bug 25456/133727 - 16/01/2013 - AMC
    /* Cambios para solicitudes múltiples : Start */
    ,
      pTipoosc IN NUMBER,
      pCIIU IN NUMBER,
      pSFINANCI IN NUMBER,
      pFConsti IN DATE,
      pCONTACTOS_PER IN T_IAX_CONTACTOS_PER,
      pDIRECCIONS_PER IN T_IAX_DIRECCIONES,
      pNacionalidad IN NUMBER,
      pDigitoide IN NUMBER
    /* Cambios para solicitudes múltiples : End */
	/* CAMBIOS De IAXIS-4538 : Start */
      ,pfefecto IN DATE,
      pcregfiscal IN NUMBER, 
      pctipiva    IN NUMBER,  
      pIMPUETOS_PER IN T_IAX_PROF_IMPUESTOS 
	/* CAMBIOS De IAXIS-4538 : End */
      )
      RETURN t_ob_error;

   FUNCTION f_get_contacto_tipo(
      psperson per_personas.sperson%TYPE,
      pcagente agentes.cagente%TYPE,
      pctipcon NUMBER,
      psmodcon IN OUT NUMBER,
      ptvalcon OUT VARCHAR,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   FUNCTION f_get_contacto(
      psperson per_personas.sperson%TYPE,
      pcagente agentes.cagente%TYPE,
      pctipcon NUMBER,
      psmodcon IN OUT NUMBER,
      ptvalcon OUT VARCHAR,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   FUNCTION f_get_dadespersona(
      psperson IN OUT per_personas.sperson%TYPE,
      pctipide IN per_personas.ctipide%TYPE,
      pnnumide IN per_personas.nnumide%TYPE,
      pcsexe IN per_personas.csexper%TYPE,
      pfnacimi IN per_personas.fnacimi%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psnip OUT per_personas.snip%TYPE,
      pnordide OUT per_personas.nordide%TYPE,
      pcestper OUT per_personas.cestper%TYPE,
      pfjubila OUT per_personas.fjubila%TYPE,
      pcmutualista OUT per_personas.cmutualista%TYPE,
      pfdefunc OUT per_personas.fdefunc%TYPE,
      ptdigitoide OUT per_personas.tdigitoide%TYPE)
      RETURN NUMBER;

   FUNCTION f_get_nacionalidaddefecto(
      psperson per_personas.sperson%TYPE,
      pcagente agentes.cagente%TYPE,
      pcpais OUT NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   FUNCTION f_get_cuentapoliza(
      psperson per_personas.sperson%TYPE,
      pcagente agentes.cagente%TYPE,
      pctipban OUT NUMBER,
      pcbancar OUT VARCHAR2,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   FUNCTION f_set_contacto(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pctipcon IN NUMBER,
      ptcomcon IN VARCHAR2,   --ETM 21406
      psmodcon IN OUT NUMBER,
      ptvalcon IN VARCHAR2,
      pcdomici IN NUMBER,   --etm 24806
      pcprefix IN NUMBER,
      errores IN OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   FUNCTION f_set_ccc(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pcnordban IN OUT NUMBER,
      pctipban IN NUMBER,
      pcbancar IN VARCHAR,
      errores IN OUT t_ob_error,
      pcdefecto IN NUMBER DEFAULT 1,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pcpagsin IN NUMBER DEFAULT NULL,
      -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
      pfvencim IN DATE DEFAULT NULL,
      -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
      ptseguri IN VARCHAR2 DEFAULT NULL,
      -- 19985 LCOL_A001-Control de las matriculas (prenotificaciones)
      pctipcc IN VARCHAR2 DEFAULT NULL   -- 20735/102170 Introduccion de cuenta bancaria
                                      )
      RETURN NUMBER;

   FUNCTION f_set_nacionalidad(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pcpais IN NUMBER,
      pcdefecto IN NUMBER DEFAULT 1,
      errores IN OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   FUNCTION f_set_identificador(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      errores IN OUT t_ob_error,
      pdefecto IN NUMBER DEFAULT 0,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pcidioma IN idiomas.cidioma%TYPE,
      -- Bug 22263 - 11/07/2012 - ETM
      ppaisexp IN NUMBER DEFAULT NULL,
      pcdepartexp IN NUMBER DEFAULT NULL,
      pcciudadexp IN NUMBER DEFAULT NULL,
      pfechaexp IN DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que se encarga de modificar un identificador
    return              : 0 Ok. 1 Error
    Bug 20441/101686 - 10/01/2012 - AMC
   *************************************************************************/
   FUNCTION f_mod_identificador(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pctipide IN NUMBER,
      pnnumide IN VARCHAR2,
      errores IN OUT t_ob_error,
      pdefecto IN NUMBER DEFAULT 0,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pcidioma IN idiomas.cidioma%TYPE,
      -- Bug 22263 - 11/07/2012 - ETM
      ppaisexp IN NUMBER DEFAULT NULL,
      pcdepartexp IN NUMBER DEFAULT NULL,
      pcciudadexp IN NUMBER DEFAULT NULL,
      pfechaexp IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_validanacionalidad(pctipper IN NUMBER, pcpais IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_gubernamental(psperson IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_ident(
      psperson IN estper_identificador.sperson%TYPE,
      pcagente IN estper_identificador.cagente%TYPE,
      pctipide IN estper_identificador.ctipide%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   -- DRA 26/09/2008: bug mantis 7567
   FUNCTION f_buscaagente(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      ptablas IN VARCHAR2)
      RETURN agentes.cagente%TYPE;

   -- JLB
   PROCEDURE traspaso_ccc(
      psperson IN per_personas.sperson%TYPE,
      pficticia_sperson IN estper_personas.sperson%TYPE,
      pcagente IN estper_ccc.cagente%TYPE);

   -- DRA 3-10-2008: bug mantis 6352
   FUNCTION f_existe_direccion(
      psperson IN per_direcciones.sperson%TYPE,
      pcagente IN per_direcciones.cagente%TYPE,
      pctipdir IN per_direcciones.ctipdir%TYPE,
      pcsiglas IN per_direcciones.csiglas%TYPE,
      ptnomvia IN per_direcciones.tnomvia%TYPE,
      pnnumvia IN per_direcciones.nnumvia%TYPE,
      ptcomple IN per_direcciones.tcomple%TYPE,
      ptdomici IN per_direcciones.tdomici%TYPE,
      pcpostal IN per_direcciones.cpostal%TYPE,
      pcpoblac IN per_direcciones.cpoblac%TYPE,
      pcprovin IN per_direcciones.cprovin%TYPE)
      RETURN per_direcciones.cdomici%TYPE;

   -- DRA 3-10-2008: bug mantis 6352
   FUNCTION f_existe_ccc(
      psperson IN per_ccc.sperson%TYPE,
      pcagente IN per_ccc.cagente%TYPE,
      pctipban IN per_ccc.ctipban%TYPE,
      pcbancar IN per_ccc.cbancar%TYPE)
      RETURN per_ccc.cnordban%TYPE;

   -- DRA 3-10-2008: bug mantis 6352
   FUNCTION f_existe_contacto(
      psperson IN per_contactos.sperson%TYPE,
      pcagente IN per_contactos.cagente%TYPE,
      pctipcon IN per_contactos.ctipcon%TYPE,
      ptcomcon IN per_contactos.tcomcon%TYPE,
      ptvalcon IN per_contactos.tvalcon%TYPE,
      pcdomici IN per_contactos.cdomici%TYPE,
      pcprefix IN per_contactos.cprefix%TYPE)
      RETURN per_contactos.cmodcon%TYPE;

   -- ini jtg
   FUNCTION f_persona_origen_int(psperson IN estper_personas.sperson%TYPE)
      RETURN NUMBER;

   FUNCTION f_get_persona_trecibido(psperson IN estper_personas.sperson%TYPE)
      RETURN VARCHAR2;

   FUNCTION f_direccion_origen_int(
      psperson IN estper_direcciones.sperson%TYPE,
      pcdomici IN estper_direcciones.cdomici%TYPE)
      RETURN NUMBER;

   FUNCTION f_get_direccion_trecibido(
      psperson IN estper_direcciones.sperson%TYPE,
      pcdomici IN estper_direcciones.cdomici%TYPE)
      RETURN VARCHAR2;

   FUNCTION f_validanif(
      pnnumide IN per_personas.nnumide%TYPE,
      pctipide IN per_personas.ctipide%TYPE,
      csexper IN per_personas.csexper%TYPE,
      fnacimi IN per_personas.fnacimi%TYPE)
      RETURN NUMBER;

   -- fin jtg
   PROCEDURE p_busca_agentes(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pcagente_visio OUT agentes.cagente%TYPE,
      pcagente_per OUT agentes.cagente%TYPE,
      ptablas IN VARCHAR2);

   FUNCTION f_get_datosper_axis(
      psip IN VARCHAR2,
      pfnacimi OUT DATE,
      ptdocidentif OUT VARCHAR2,
      psexo OUT NUMBER)
      RETURN NUMBER;

   -- ACC 15122008
   -- Comprova que la direcció d'un no estigui donada d'alta en un altre
   FUNCTION f_valida_misma_direccion(
      psperson1 IN NUMBER,
      pcdomici1 IN NUMBER,
      psperson2 IN NUMBER,
      pcdomici2 OUT NUMBER)
      RETURN NUMBER;

   -- dra 9-1-08: bug mantis 8660 (funció sobrecarregada)
   FUNCTION f_get_dadespersona(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      persona OUT personas%ROWTYPE)
      RETURN NUMBER;

   /*************************************************************************
          Nueva función que servirá para modificar los datos básicos de una persona
   *************************************************************************/
   FUNCTION f_set_basicos_persona(
      psperson IN per_personas.sperson%TYPE,
      pctipper IN per_personas.ctipper%TYPE,
      pctipide IN per_personas.ctipide%TYPE,
      pnnumide IN per_personas.nnumide%TYPE,
      pcsexper IN per_personas.csexper%TYPE,
      pfnacimi IN per_personas.fnacimi%TYPE,
      pswpubli IN per_personas.swpubli%TYPE,
      ptablas IN VARCHAR2,
      pswrut IN NUMBER,
      pcpreaviso IN per_personas.cpreaviso%TYPE,
      perrores OUT t_ob_error)
-- BUG 21270/107049 - 13/02/2012 - JMP - Tractament errors crida a PAC_CON.F_ALTA_PERSONA
   RETURN NUMBER;

   /*************************************************************************
          Borrará la información de las tablas per_irpfdescen ,
          per_irpfmayores y per_irpf, dependiendo del modo borra de las tablas "EST".
   *************************************************************************/
   FUNCTION f_del_irpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      ptablas IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        Esta función debe realizar un insert  y en caso de existir un update sobre la tabla per_irpf,
        dependiendo del modo de entrada lo realizará sobre las tablas estper_irpf.

        Bug 12716 - 26/03/2010 - AMC - Se añade los parametros pfmovgeo y pcpago
   *************************************************************************/
   FUNCTION f_set_irpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pcsitfam IN NUMBER,
      pcnifcon IN VARCHAR2,
      pcgrado IN NUMBER,
      pcayuda IN NUMBER,
      pipension IN NUMBER,
      pianuhijos IN NUMBER,
      pprolon IN NUMBER,
      prmovgeo IN NUMBER,
      ptablas IN VARCHAR2,
      pfmovgeo IN DATE,
      pcpago IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
        Realizará un insert y en caso de existir modificará el registro, tener en cuenta
        el campo ptablas indica si se realiza sobre las est o sobre las tablas reales.
    *************************************************************************/
   FUNCTION f_set_irpfmayores(
      psperson IN per_irpfmayores.sperson%TYPE,
      pcagente IN per_irpfmayores.cagente%TYPE,
      pnano IN per_irpfmayores.nano%TYPE,
      pnorden IN per_irpfmayores.norden%TYPE,
      pfnacimi IN per_irpfmayores.fnacimi%TYPE,
      pcgrado IN per_irpfmayores.cgrado%TYPE,
      pcrenta IN per_irpfmayores.crenta%TYPE,
      pnviven IN per_irpfmayores.nviven%TYPE,
      ptablas IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
        Realizará un insert y en caso de existir modificará el registro, tener en cuenta
        el campo ptablas indica si se realiza sobre las est o sobre las tablas reales.

        Bug 12716 - 25/03/2010 - AMC - Se añade el parametro pfadopcion
    *************************************************************************/
   FUNCTION f_set_irpfdescen(
      psperson IN per_irpfdescen.sperson%TYPE,
      pcagente IN per_irpfdescen.cagente%TYPE,
      pnano IN per_irpfdescen.nano%TYPE,
      pnorden IN per_irpfdescen.norden%TYPE,
      pfnacimi IN per_irpfdescen.fnacimi%TYPE,
      pfadopcion IN per_irpfdescen.fadopcion%TYPE,
      pcenter IN per_irpfdescen.center%TYPE,
      pcgrado IN per_irpfdescen.cgrado%TYPE,
      ptablas IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_irpfmayor(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pnorden IN NUMBER,
      pidioma IN NUMBER,
      ptablas IN VARCHAR2,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_irpfdescen(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pnorden IN NUMBER,
      pidioma IN NUMBER,
      ptablas IN VARCHAR2,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_irpf(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pnano IN NUMBER,
      pidioma IN NUMBER,
      ptablas IN VARCHAR2,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    función que devuelve número de años para declarar el irpf de una persona,
    si la persona existe se le devolverá el máximo más uno sino existiera se
    le devolvería el actual año
   *************************************************************************/
   FUNCTION f_get_anysirpf(psperson IN NUMBER, pcagente IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
     función que recuperará todas la personas dependiendo del modo.
     publico o no. servirá para todas las pantallas donde quieran utilizar el
     buscador de personas.
   *************************************************************************/
   FUNCTION f_get_persona_generica(
      pnumide IN VARCHAR2,
      pnombre IN VARCHAR2,
      pnsip IN VARCHAR2,
      pnom IN VARCHAR2,
      pcognom1 IN VARCHAR2,
      pcognom2 IN VARCHAR2,
      pctipide IN NUMBER,
      pcagente IN NUMBER,
      pmodo_swpubli IN VARCHAR2,
      psquery OUT CLOB)
      RETURN NUMBER;

   -- ini t.8063
   FUNCTION f_buscaagente_publica(
      psperson IN per_personas.sperson%TYPE,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN per_detper.cagente%TYPE;

-- fin t.8063

   --BUG 10074 - JTS - 18/05/2009
   /*************************************************************************
   Obté la select amb els profesionals associats a una persona
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_profesionales(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Obté la select amb les companyies associades a una persona
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_companias(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Obté la select amb els agents associats a una persona
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_agentes(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Obté la select amb els sinistres associats a una persona
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_siniestros(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Obté la select amb les pólisses en que una persona es prenedora
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_poltom(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Obté la select amb les pólisses en que una persona es assegurada
   param in psperson   : Codi sperson
   param in pidioma    : Codi idioma
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_polase(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

--Fi BUG 10074 - JTS - 18/05/2009
--BUG 10371 - JTS - 09/06/2009
   /*************************************************************************
   Obté la select amb els paràmetres per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pidioma    : Codi idioma
   param in ptots      : 0.- Només retorna els paràmetres contestats
                         1.- Retorna tots els paràmetres
   param in pctipper   : Codi Tipus persona
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pidioma IN NUMBER,
      pcvisible IN NUMBER,
      ptots IN NUMBER,
      ptablas IN VARCHAR2,
      pctipper IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

            /*************************************************************************
   Obté la select amb els paràmetres per persona
      pcparam IN NUMBER,
      pcidioma in number,
   param out psquery   : Select
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_get_obparpersona(pcparam IN VARCHAR2, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Inserta el paràmetre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   param in pnvalpar   : Resposta numérica
   param in ptvalpar   : Resposta text
   param in pfvalpar   : Resposta data
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_ins_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      pnvalpar IN NUMBER,
      ptvalpar IN VARCHAR2,
      pfvalpar IN DATE,
      ptablas IN VARCHAR2,
      perrores OUT t_ob_error)
-- BUG 21270/107049 - 13/02/2012 - JMP - Tractament errors crida a PAC_CON.F_ALTA_PERSONA
   RETURN NUMBER;

   /*************************************************************************
   Esborra el paràmetre per persona
   param in psperson   : Codi sperson
   param in psperson   : Codi agent
   param in pcparam    : Codi parametre
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   FUNCTION f_del_parpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcparam IN VARCHAR2,
      ptablas IN VARCHAR2)
      RETURN NUMBER;

--Fi BUG 10371 - JTS - 09/06/2009

   /*************************************************************************
   Devuelve el idioma del agente
   param in pcagente   : Codi agente
   param out pcidioma  : Idioma del agente
   return              : 0.- OK, 1.- KO

   Bug 10684 - 21/12/2009 - AMC
   *************************************************************************/
   FUNCTION f_get_idioma_age(pcagente IN NUMBER, pcidioma OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Traspàs d'una determinada adreça a una determinada persona (taules EST)
      param in psperson_desti   : persona destí a la que se li assignarà l'adreça
      param in pcagente         : agent de visió a la qual se li ha d'assignar l'adreça
      param in pcidioma         : idioma
      param in psperson_origen  : adreça origen
      param in pcdomici_origen  : adreça origen
      param in pcdelete         : flag (0/1) per indicar si cal esborrar les adreces que ja tingui la persona
      return                    : O -> Tot ok
                                  codi_error -> Error
   ***********************************************************************/
   FUNCTION f_traspaso_direccion_fija(
      psperson_desti IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      psperson_origen IN NUMBER,
      pcdomici_origen IN NUMBER,
      pcdelete IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   -- BUG14307:DRA:11/05/2010:Inici
   /**************************************************************
     Funció que valida si un numero de CASS té el format correcte
   **************************************************************/
   FUNCTION f_valida_cass(pnumcass IN VARCHAR2)
      RETURN NUMBER;

-- BUG14307:DRA:11/05/2010:Fi
/*************************************************************************
      FUNCTION función que nos comprueba si la persona tiene el mismo nnumide
      param in pnnumide    : Nnumide que vamos a comprobar
      param out pduplicada : Miramos si esta duplicada
      return           : código de error

       ---- Bug 17563 : AGA800 - data naixement - 08/03/2011 - XPL
   *************************************************************************/
   FUNCTION f_persona_duplicada(
      psperson IN NUMBER,
      pnnumide IN VARCHAR2,
      pcsexper IN NUMBER,
      pfnacimi IN DATE,
      psnip IN VARCHAR2,
      pcagente IN NUMBER,
      pswpubli IN NUMBER,
      pctipide IN NUMBER,
      pduplicada OUT NUMBER,
      psolicit IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

      /**************************************************************
     Funció que nos devolerá el agente del detalle de la persona que el agente del usuario conectado
     puede visualizar.
   **************************************************************/
   FUNCTION f_get_agente_detallepersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcempres IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /**************************************************************
   Procedimiento para borrar una persona relacionada
   Bug.: 18941
   /**************************************************************/
   PROCEDURE p_del_persona_rel(
      psperson IN per_personas_rel.sperson%TYPE,
      pcagente IN per_personas_rel.cagente%TYPE,
      psperson_rel IN per_personas_rel.sperson_rel%TYPE,
      pcagrupa IN per_personas_rel.cagrupa%TYPE, --IAXIS-3670 16/04/2019 AP
      errores OUT t_ob_error,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST');

   /**************************************************************
   Procedimiento para borrar una persona relacionada
   Bug.: 18941
   /**************************************************************/
   FUNCTION f_set_persona_rel(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      psperson_rel IN NUMBER,
      pctipper_rel IN NUMBER,
      ppparticipacion IN NUMBER,
      pislider IN NUMBER,   -- BUG 0030525 - FAL - 01/04/2014
      errores IN OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST',
    ptlimit IN VARCHAR2,
      pcagrupa IN NUMBER,
      pfagrupa IN DATE)
      RETURN NUMBER;

   /**************************************************************
     Procedimiento para borrar un regimen fiscal
     Bug.: 18941
     /**************************************************************/
   PROCEDURE p_del_regimenfiscal(
      psperson IN per_personas_rel.sperson%TYPE,
      pcagente IN per_personas_rel.cagente%TYPE,
      pfefecto IN DATE,
      errores OUT t_ob_error,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'EST');

   /*************************************************************************
    Nueva función que se encarga de insertar el régimen fiscal
    return              : 0 Ok. 1 Error
    Bug.: 18942
   *************************************************************************/
   FUNCTION f_set_regimenfiscal(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      pcregfiscal IN NUMBER,
      pcregfisexeiva IN NUMBER DEFAULT 0,  --AP CONF-190
      pctipiva       IN NUMBER,
      errores IN OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que se encarga de borrar un registro de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   *************************************************************************/
   FUNCTION f_del_sarlaft(
      psperson IN per_personas_rel.sperson%TYPE,
      pcagente IN per_personas_rel.cagente%TYPE,
      pfefecto IN DATE,
      errores OUT t_ob_error,
      pcidioma IN idiomas.cidioma%TYPE,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que se encarga de insertar un registro de SARLAFT
    return              : 0 Ok. 1 Error
    Bug.: 18943
   *************************************************************************/
   FUNCTION f_set_sarlaft(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      errores IN OUT t_ob_error,
      ptablas IN VARCHAR2 DEFAULT 'POL')
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que obtiene información de los gestores/empleados de la persona
    param in psperson   : Codigo sperson
    param in pidioma    : Codigo idioma
    param out psquery   : Select
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_gestores_empleados(
      psperson IN NUMBER,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que obtiene información de los representantes/promotores de la persona
    param in psperson   : Codigo sperson
    param in pidioma    : Codigo idioma
    param out psquery   : Select
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_represent_promotores(
      psperson IN NUMBER,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que obtiene información de los representantes/promotores asociados a un coordinador
    param in psperson   : Codigo sperson
    param in pidioma    : Codigo idioma
    param out psquery   : Select
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_coordinadores(psperson IN NUMBER, pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Nueva funcion que obtiene información de las listas oficiales del estado de la persona
    param in psperson   : Codigo sperson
    param in pcclalis   : Identificador de clase de lista
    param in pidioma    : Codigo idioma
    param out psquery   : Select
    return              : 0.- OK, 1.- KO
    Bug 18947
   *************************************************************************/
   FUNCTION f_get_listas_oficiales(
      psperson IN NUMBER,
      pcclalis IN NUMBER,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

    /*************************************************************************
     función que recuperará todas la personas dependiendo del modo.
     publico o no. servirá para todas las pantallas donde quieran utilizar el
     buscador de personas.

     Bug 20044/97773 - 12/11/2011 - AMC
   *************************************************************************/
   FUNCTION f_get_persona_generica_cond(
      pnumide IN VARCHAR2,
      pnombre IN VARCHAR2,
      pnsip IN VARCHAR2,
      pnom IN VARCHAR2,
      pcognom1 IN VARCHAR2,
      pcognom2 IN VARCHAR2,
      pctipide IN NUMBER,
      pcagente IN NUMBER,
      pmodo_swpubli IN VARCHAR2,
      pcond IN VARCHAR2,
      psquery OUT CLOB)
      RETURN NUMBER;

   /*************************************************************************
     Función que inserta o actualiza los datos de un documento asociado a la persona

     Bug 20126 - APD - 23/11/2011 - se crea la funcion
   *************************************************************************/
   FUNCTION f_set_docpersona(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pfcaduca IN DATE,
      ptobserva IN VARCHAR2,
      piddocgedox IN NUMBER,
      ptdocumento IN NUMBER DEFAULT NULL,
      pedocumento IN NUMBER DEFAULT NULL,
      pfedo IN DATE DEFAULT NULL)
      RETURN NUMBER;

-- BUG20790:APD:03/01/2012:Inici
/**************************************************************
  Funció que valida una CCC
**************************************************************/
   FUNCTION f_valida_ccc(
      psperson IN NUMBER,
      pcnordban IN NUMBER,
      pcagente IN NUMBER,
      pcbancar IN VARCHAR2)
      RETURN NUMBER;

-- BUG20790:APD:03/01/2012:Fi

   /**************************************************************
     Funció que valida que si hay una ccc con pagos de siniestros
     param in psperson : codigo de persona
     param in pcagente : codigo del agente
     param out pcodilit : codigo del literal a mostrar
     return codigo error : 0 - ok ,codigo de error
     BUG 20958/104928 - 24/01/2012 - AMC

     Bug 21867/111852 - 29/03/2012 - AMC
   **************************************************************/
   FUNCTION f_valida_pagoccc(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcnordban IN NUMBER,
      pcodilit IN OUT NUMBER)
      RETURN NUMBER;

   /***************************************************************************
           Función bloquear una persona por LOPD
           Traspasará los datos de la persona a las tablas LOPD
   *****************************************************************************/
   FUNCTION f_bloquear_persona(psperson IN NUMBER, pcagente IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER;

   /***************************************************************************
   Función desbloquear una persona por LOPD
   Volverá a deja la persona igual que antes que el traspaso a las tablas LOPD
   *****************************************************************************/
   FUNCTION f_desbloquear_persona(psperson IN NUMBER, pcagente IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER;

   /***************************************************************************
   Función que prepara a la persona per ser borrada
   *****************************************************************************/
   FUNCTION f_borrar_persona_lopd(psperson IN NUMBER, pcagente IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER;

      /***************************************************************************
   Bloquear la persona, traspasando los datos de LOPD
   *****************************************************************************/
   FUNCTION f_persona_lopd_bloqueo(
      psperson IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /***************************************************************************
Retroceso de los datos de LOPD
*****************************************************************************/
   FUNCTION f_persona_lopd_retroceso(
      psperson IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /***************************************************************************
Borrar  los datos de LOPD
*****************************************************************************/
   FUNCTION f_persona_lopd_borrar(
      psperson IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

           /***************************************************************************
   Función que prepara a la persona per ser borrada
   *****************************************************************************/
   FUNCTION f_set_persona_lopd(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcesion IN NUMBER,
      ppublicidad IN NUMBER,
      pacceso IN NUMBER,
      prectificacion IN NUMBER,
      pcidioma IN NUMBER)
      RETURN NUMBER;

   --Se mira si la póliza tiene una figura bloqueada por LOPD.
   FUNCTION f_esta_persona_bloqueada(psseguro IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER;

   --Se mira si la póliza tiene una figura bloqueada por LOPD en seguros y siniestros
   FUNCTION f_esta_persona_bloqueada_sinis(
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pcagente IN NUMBER)
      RETURN NUMBER;

   /**************************************************************
      Funció que inserta en PER_CONTACTOS_AUT
      param in psperson : codigo de persona
      param in pcagente : codigo del agente
      param in pctipcon
      param in psmodcon
      param in ptvalcon
      param in ptipmov
      return codigo error : 0 - ok ,codigo de error
      BUG 18949/103391 - 31/01/2012 - AMC
    **************************************************************/
   FUNCTION f_ins_contacto_aut(
      psperson IN per_personas.sperson%TYPE,
      pcagente IN agentes.cagente%TYPE,
      pctipcon IN NUMBER,
      psmodcon IN OUT NUMBER,
      ptvalcon IN VARCHAR2,
      ptipmov IN VARCHAR2,
      pcidioma IN NUMBER,
      pcdomici IN NUMBER,
      errores IN OUT t_ob_error)
      RETURN NUMBER;

   /**************************************************************
     Funció que inserta en PER_DIRECCIONES_AUT
     return codigo error : 0 - ok ,codigo de error
     BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_ins_direccion_aut(
      psperson IN estper_direcciones.sperson%TYPE,
      pcagente IN estper_direcciones.cagente%TYPE,
      pcdomici IN OUT estper_direcciones.cdomici%TYPE,
      pctipdir IN estper_direcciones.ctipdir%TYPE,
      pcsiglas IN estper_direcciones.csiglas%TYPE,
      ptnomvia IN estper_direcciones.tnomvia%TYPE,
      pnnumvia IN estper_direcciones.nnumvia%TYPE,
      ptcomple IN estper_direcciones.tcomple%TYPE,
      ptdomici IN estper_direcciones.tdomici%TYPE,
      pcpostal IN estper_direcciones.cpostal%TYPE,
      pcpoblac IN estper_direcciones.cpoblac%TYPE,
      pcprovin IN estper_direcciones.cprovin%TYPE,
      pcusuari IN estper_direcciones.cusuari%TYPE,
      pfmovimi IN estper_direcciones.fmovimi%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      errores IN OUT t_ob_error,
      ptipmov IN VARCHAR2 DEFAULT 'M',
      pcviavp IN estper_direcciones.cviavp%TYPE,
      pclitvp IN estper_direcciones.clitvp%TYPE,
      pcbisvp IN estper_direcciones.cbisvp%TYPE,
      pcorvp IN estper_direcciones.corvp%TYPE,
      pnviaadco IN estper_direcciones.nviaadco%TYPE,
      pclitco IN estper_direcciones.clitco%TYPE,
      pcorco IN estper_direcciones.corco%TYPE,
      pnplacaco IN estper_direcciones.nplacaco%TYPE,
      pcor2co IN estper_direcciones.cor2co%TYPE,
      pcdet1ia IN estper_direcciones.cdet1ia%TYPE,
      ptnum1ia IN estper_direcciones.tnum1ia%TYPE,
      pcdet2ia IN estper_direcciones.cdet2ia%TYPE,
      ptnum2ia IN estper_direcciones.tnum2ia%TYPE,
      pcdet3ia IN estper_direcciones.cdet3ia%TYPE,
      ptnum3ia IN estper_direcciones.tnum3ia%TYPE,
      plocalidad IN estper_direcciones.localidad%TYPE
                                                     -- Bug 24780/130907 - 05/12/2012 - AMC
   )
      RETURN NUMBER;

    /**************************************************************
     Funció que actualiza PER_CONTACTOS_AUT
     return codigo error : 0 - ok ,codigo de error
     BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_set_contacto_aut(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcmodcon IN NUMBER,
      pnorden IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      pcidioma IN NUMBER,
      errores IN OUT t_ob_error)
      RETURN NUMBER;

    /**************************************************************
     Funció que actualiza PER_DIRECCIONES_AUT
     return codigo error : 0 - ok ,codigo de error
     BUG 18949/103391 - 02/02/2012 - AMC
   **************************************************************/
   FUNCTION f_set_direccion_aut(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      pcdomici IN NUMBER,
      pnorden IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      pcidioma IN NUMBER,
      errores IN OUT t_ob_error)
      RETURN NUMBER;

   --INI BUG 22642 -- ETM --24/07/2012
    /**************************************************************
       FUNCION f_get_inquiaval
       Obtiene la select con los inquilinos avalistas
         param in psperson   : Codi sperson
         paran in pcidioma  :codi de idioma
          param in pctipfig    : Codi id de avalista o inqui(1 inquilino , 2 Avalista )
         param out psquery   : Select
         return              : 0.- OK, 1.- KO
    **************************************************************/
   FUNCTION f_get_inquiaval(
      psperson IN NUMBER,
      pctipfig IN NUMBER,
      -- 1 inquilino , 2 Avalista Desde java le pasamos el tipo
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

   /**************************************************************
        FUNCION f_get_gescobro
        Obtiene la select con los gestores de cobro
          param in psperson   : Codi sperson
          paran in pcidioma  :codi de idioma
          param out psquery   : Select
          return              : 0.- OK, 1.- KO
     **************************************************************/
   FUNCTION f_get_gescobro(psperson IN NUMBER, pcidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER;

--FIN BUG 22642 -- ETM --24/07/2012

   --*********************************************************
    --   F_NIF  : Obte el nif o el cif amb la lletra correcta.
    --            Si hi ha problema retorna un numero de error, si no 0.
    --   Retorna:
    --   0 - nif correcte.
    --   101249 - nif/cif null.
    --   101250 - longitud nif/cif incorrecte. --> 9902747
    --   101251 - lletra nif/cif incorrecte. --> 9903641
    --   101506 - digit cif incorrecte.
    --   101657 - nif sense lletra.
    --   MSR : Simplificacions i millora 29/01/2008
    --   JTS : Adaptació nou format d'identificador de sistema 14/01/2009
--*********************************************************
   FUNCTION f_nif(pctipide IN NUMBER, pnnumide IN OUT VARCHAR2)
      RETURN NUMBER;

--Bug 25349 - XVM - 27/12/2012
   FUNCTION f_existe_identificador(
      pidenti IN identificadores.nnumide%TYPE,
      pctipide IN NUMBER,
      pspereal IN per_personas.sperson%TYPE DEFAULT NULL)
      RETURN NUMBER;

 /*************************************************************************
   FUNCTION f_pagador_alt
   Funcion que agrega o quita los pagadores alternativos relacionados a un tercero
   psperson     IN NUMBER Tercero
   pcagente     IN NUMBER Agente
   psperson_rel IN NUMBER Pagador alternativo a agregar
   pctipper_rel IN NUMBER Tipo de persona relacionada
   pcoperacion  IN NUMBER 1 - Agregar/Habilitar pagador alternativo; 2 - Dar de baja al Pagador Alternativo
   La función devuelve 0 si ha ido bien 1 si hay error
   IAXIS-2091 Convivencia Pagador Altertnativo
   *************************************************************************/
   --
   FUNCTION f_pagador_alt (psperson     IN NUMBER,
                           psperson_rel IN NUMBER,
                           pctipper_rel IN NUMBER DEFAULT NULL,
                           pcoperacion  IN NUMBER)
   RETURN NUMBER; 
   -- Bug 25542 - APD - se crea la funcion
   FUNCTION f_actualiza_fantiguedad(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pfantiguedad IN DATE,
      pnmovimi IN NUMBER,
      pffin IN DATE)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que dado un sseguro (poliza) busca todas las personas asociadas a
   la poliza para actualizar la antiguedad de cada persona
   return              : 0.- OK, 1.- KO
   *************************************************************************/
   -- Bug 25542 - APD - se crea la funcion
   FUNCTION f_antiguedad_personas_pol(psseguro IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Proceso diario que actualiza la antiguedad de una persona
   *************************************************************************/
   -- Bug 25542 - APD - se crea la funcion
   PROCEDURE p_proceso_antiguedad(
      psperson IN NUMBER,
      pcagrupa IN NUMBER,
      pfecha IN DATE,
      psproces OUT NUMBER);

   /****************************************************************************
      F_PER_PERSONA: Obtenir el sexe i la data de naixement
        d'una persona.
   ****************************************************************************/
   -- 24497.NMM.#6.
   FUNCTION f_persona_dades(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psexe OUT NUMBER,
      pdatanaix OUT DATE)
      RETURN NUMBER;

    -- BUG 26968 - FAL - 04/07/2013
   /****************************************************************************
      F_FORMAT_NIF: Formateo del Nif
        d'una persona.
   ****************************************************************************/
   FUNCTION f_format_nif(
      pnnumide IN VARCHAR2,
      pctipide IN NUMBER,
      psperson IN NUMBER,
      pmode IN VARCHAR2)
      RETURN VARCHAR2;

-- FI BUG 26968 - FAL - 04/07/2013

   -- Bug 26318 - 10/10/2013 - JMG - Inicio #155391 Anotación en la agenda de las pólizas
/*************************************************************************
  FUNCTION f_set_agensegu_rol
     Obtiene los registros de las polizas asociadas al rol  e inserta un apunte en la agenda
     param in psperson: Codigo de la persona
     param in pcidioma: idioma
  *************************************************************************/
   FUNCTION f_set_agensegu_rol(
      psperson IN NUMBER,
      pmodo IN VARCHAR2,
      pcidioma IN idiomas.cidioma%TYPE)
      RETURN NUMBER;

-- Bug 26318 - 10/10/2013 - JMG - Fin #155391 Anotación en la agenda de las pólizas

   -- BUG 26968/0155105 - FAL - 15/10/2013
   FUNCTION f_desformat_nif(pnnumide IN VARCHAR2, pctipide IN NUMBER)
      RETURN VARCHAR2;

-- FI BUG 26968/0155105

   -- Bug 26318 envio de personas duplicadas a SAp
   FUNCTION f_persona_duplicada_nnumide(psperson IN NUMBER)
      RETURN NUMBER;

-- Fi bug 26318/ 157478

   /****************************************************************************
      F_CONVERTIR_APUBLICA: Convierte una persona a pública

      Bug 29166/160004 - 29/11/2013 - AMC
   ****************************************************************************/
   FUNCTION f_convertir_apublica(psperson NUMBER)
      RETURN NUMBER;

   /****************************************************************************
      F_EXISTE_ESTPERSONA: Mira si una persona ya ha sido traspasada a las tablas est

      Bug 29324/166247 - 21/12/2014- AMC
   ****************************************************************************/
   FUNCTION f_existe_estpersona(psperson IN NUMBER, psseguro IN NUMBER, pexiste IN OUT NUMBER)
      RETURN NUMBER;

      FUNCTION f_set_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      pfdiligencia IN DATE,
      pcauttradat IN NUMBER,
      pcrutfcc IN NUMBER,
      pcestconf IN NUMBER,
      pfconfir IN DATE,
      pcvinculacion IN NUMBER,
      ptvinculacion IN VARCHAR2,
      per_cdeptosol IN NUMBER,
      per_tdeptosol IN VARCHAR2,
      per_cciusol IN NUMBER,
      per_tciusol IN VARCHAR2,
      pcvintomase IN NUMBER,
      ptvintomase IN VARCHAR2,
      pcvintomben IN NUMBER,
      ptvintombem IN VARCHAR2,
      pcvinaseben IN NUMBER,
      ptvinasebem IN VARCHAR2,
      pcactippal IN NUMBER,
      ppersectorppal IN NUMBER,
      pnciiuppal IN NUMBER,
      ptcciiuppal IN VARCHAR2,
      ppertipoactivppal IN VARCHAR2,
      ptocupacion IN VARCHAR2,
      ptcargo IN VARCHAR2,
      ptempresa IN VARCHAR2,
      ptdirempresa IN VARCHAR2,
      ppercdeptoofic IN NUMBER,
      ppertdeptoofic IN VARCHAR2,
      ppercciuofic IN NUMBER,
      ppertciuofic IN VARCHAR2,
      pttelempresa IN VARCHAR2,
      pcactisec IN VARCHAR2,
      pnciiusec IN NUMBER,
      ptcciiusec IN VARCHAR2,
      ptdirsec IN VARCHAR2,
      pttelsec IN VARCHAR2,
      ptprodservcom IN VARCHAR2,
      piingresos IN NUMBER,
      piactivos IN NUMBER,
      pipatrimonio IN NUMBER,
      piegresos IN NUMBER,
      pipasivos IN NUMBER,
      piotroingreso IN NUMBER,
      ptconcotring IN VARCHAR2,
      pcmanrecpub IN NUMBER,
      pcpodpub IN NUMBER,
      pcrecpub IN NUMBER,
      pcvinperpub IN NUMBER,
      ptvinperpub IN VARCHAR2,
      pcdectribext IN NUMBER,
      ptdectribext IN VARCHAR2,
      ptorigfond IN VARCHAR2,
      pctraxmodext IN NUMBER,
      pttraxmodext IN VARCHAR2,
      pcprodfinext IN NUMBER,
      pcctamodext IN NUMBER,
      ptotrasoper IN VARCHAR2,
      pcreclindseg IN NUMBER,
      ptciudadsuc IN NUMBER,
      ptpaisuc IN NUMBER,
      ptdepatamentosuc IN NUMBER,
      ptciudad IN NUMBER,
      ptdepatamento IN NUMBER,
      ptpais IN NUMBER,
      ptlugarexpedidoc IN NUMBER,
      presociedad IN NUMBER,
      ptnacionali2 IN NUMBER,
      pngradopod IN NUMBER,
      pngozrec IN NUMBER,
      pnparticipa IN NUMBER,
      pnvinculo IN NUMBER,
      pntipdoc IN NUMBER,
      pfexpedicdoc IN DATE,
      pfnacimiento IN DATE,
      pnrazonso IN VARCHAR2,
      ptnit IN VARCHAR2,
      ptdv IN VARCHAR2,
      ptoficinapri IN VARCHAR2,
      pttelefono IN VARCHAR2,
      ptfax IN VARCHAR2,
      ptsucursal IN VARCHAR2,
      pttelefonosuc IN VARCHAR2,
      ptfaxsuc IN VARCHAR2,
      pctipoemp IN VARCHAR2,
      ptcualtemp IN VARCHAR2,
      ptsector IN VARCHAR2,
      pcciiu IN NUMBER,
      ptactiaca IN VARCHAR2,
      ptmailjurid IN VARCHAR2,
      ptrepresentanle IN VARCHAR2,
      ptsegape IN VARCHAR2,
      ptnombres IN VARCHAR2,
      ptnumdoc IN VARCHAR2,
      ptlugnaci IN VARCHAR2,
      ptnacionali1 IN VARCHAR2,
      ptindiquevin IN VARCHAR2,
      pper_papellido IN VARCHAR2,
      pper_sapellido IN VARCHAR2,
      pper_nombres IN VARCHAR2,
      pper_tipdocument IN NUMBER,
      pper_document IN VARCHAR2,
      pper_fexpedicion IN DATE,
      pper_lugexpedicion IN NUMBER,
      pper_fnacimi IN DATE,
      pper_lugnacimi IN NUMBER,
      pper_nacion1 IN NUMBER,
      pper_direreci IN VARCHAR2,
      pper_pais IN NUMBER,
      pper_ciudad IN NUMBER,
      pper_departament IN NUMBER,
      pper_email IN VARCHAR2,
      pper_telefono IN VARCHAR2,
      pper_celular IN VARCHAR2,
      pnrecpub IN NUMBER,
      ptpresetreclamaci IN NUMBER,
      pper_tlugexpedicion IN VARCHAR2,
      pper_tlugnacimi IN VARCHAR2,
      pper_tnacion1 IN VARCHAR2,
      pper_tnacion2 IN VARCHAR2,
      pper_tpais IN VARCHAR2,
      pper_tdepartament IN VARCHAR2,
      pper_tciudad IN VARCHAR2,
      pemptpais IN VARCHAR2,
      pemptdepatamento IN VARCHAR2,
      pemptciudad IN VARCHAR2,
      pemptpaisuc IN VARCHAR2,
      pemptdepatamentosuc IN VARCHAR2,
      pemptciudadsuc IN VARCHAR2,
      pemptlugnaci IN VARCHAR2,
      pemptnacionali1 IN VARCHAR2,
      pemptnacionali2 IN VARCHAR2,
      pcsujetooblifacion IN NUMBER,
      ptindiqueoblig IN VARCHAR2,
      pper_paisexpedicion IN NUMBER,
      pper_tpaisexpedicion IN VARCHAR2,
      pper_depexpedicion IN NUMBER,
      pper_tdepexpedicion IN VARCHAR2,
      pper_paislugnacimi IN NUMBER,
      pper_tpaislugnacimi IN VARCHAR2,
      pper_deplugnacimi IN NUMBER,
      pper_tdeplugnacimi IN VARCHAR2,
      pemp_paisexpedicion IN NUMBER,
      pemp_tpaisexpedicion IN VARCHAR2,
      pemp_depexpedicion IN NUMBER,
      pemp_tdepexpedicion IN VARCHAR2,
      pemp_paislugnacimi IN NUMBER,
      pemp_tpaislugnacimi IN VARCHAR2,
      pemp_deplugnacimi IN NUMBER,
      pemp_tdeplugnacimi IN VARCHAR2,
      pemp_lugnacimi IN NUMBER,
      pemp_tlugnacimi IN VARCHAR2,
      pemp_fexpedicion IN DATE,
      pemp_lugexpedicion IN NUMBER,
      pemp_tlugexpedicion IN VARCHAR2,
      pper_nacion2 IN NUMBER,
      pper_pcciusol IN NUMBER DEFAULT NULL,
      pper_pcsucursal IN NUMBER, --CP0615M_SYS_PERS AP 28/12/2018
      pper_pctipsol IN NUMBER DEFAULT NULL,
      pper_pcsector IN NUMBER DEFAULT NULL,
      pper_pctipact IN VARCHAR2 DEFAULT NULL,
      pper_pcciuofc IN NUMBER DEFAULT NULL,
      pper_pcdepofc IN NUMBER DEFAULT NULL,
      pemp_tmailrepl  IN VARCHAR2  DEFAULT NULL,
      pemp_tdirsrepl IN VARCHAR2 DEFAULT NULL,
      pemp_cciurrepl IN NUMBER DEFAULT NULL,
      pemp_tciurrepl IN VARCHAR2,
      pemp_cdeprrepl IN NUMBER DEFAULT NULL,
      pemp_tdeprrepl IN VARCHAR2,
      pemp_cpairrepl IN NUMBER DEFAULT NULL,
      pemp_tpairrepl IN VARCHAR2,
      pemp_ttelrepl IN NUMBER DEFAULT NULL,
      pemp_tcelurepl IN NUMBER DEFAULT NULL,
      pcdeptoentrev IN NUMBER DEFAULT NULL,
      ptdeptoentrev IN VARCHAR2,
      pcciuentrev  IN NUMBER DEFAULT NULL,
      ptciuentrev IN VARCHAR2,
      pfentrevista IN DATE DEFAULT NULL,
      pthoraentrev IN VARCHAR2 DEFAULT NULL,
      ptagenentrev IN VARCHAR2 DEFAULT NULL,
      ptasesentrev IN VARCHAR2 DEFAULT NULL,
      ptobseentrev IN VARCHAR2 DEFAULT NULL,
      pcrestentrev IN NUMBER DEFAULT NULL,
      ptobseconfir IN VARCHAR2 DEFAULT NULL,
      pthoraconfir IN VARCHAR2 DEFAULT NULL,
      ptemplconfir IN VARCHAR2 DEFAULT NULL,
    pcorigenfon  IN VARCHAR2 DEFAULT NULL,
      pcclausula1  IN NUMBER DEFAULT NULL, --TCS-9 AP 12/02/2019
      pcclausula2  IN NUMBER DEFAULT NULL, --TCS-9 AP 12/02/2019
      pcconfir     IN NUMBER DEFAULT NULL,--IAXIS-3287 01/04/2019
    mensajes OUT t_iax_mensajes)   -- CP0727M_SYS_PERS_Val - Inc. 2169 - ACL - 23/11/2018
      RETURN NUMBER;

   FUNCTION f_del_datsarlatf(
      pssarlaft IN NUMBER,
      pfradica IN DATE,
      psperson IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_detsarlatf_dec(
      pndeclara IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      pctipoid IN NUMBER,
      pcnumeroid IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pcmanejarec IN NUMBER,
      pcejercepod IN NUMBER,
      pcgozarec IN NUMBER,
      pcdeclaraci IN NUMBER,
      pcdeclaracicual IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_detsarlatf_act(
      pnactivi IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detsarlatf_act(
      pnactivi IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_detsarlatf_act(
      pnactivi IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      pctipoprod IN VARCHAR2,
      pcidnumprod IN VARCHAR2,
      ptentidad IN VARCHAR2,
      pcmonto IN VARCHAR2,
      pcciudad IN NUMBER,
      pcpais IN NUMBER,
      pcmoneda IN VARCHAR2,
      pscpais IN VARCHAR2,
      pstdepb IN VARCHAR2,
      ptdepb IN NUMBER,
      pscciudad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_detsarlaft_rec(
      pnrecla IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_detsarlaft_rec(
      pnrecla IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_detsarlaft_rec(
      pnrecla IN NUMBER,
      psperson IN NUMBER,
      pssarlaft IN NUMBER,
      pcanio IN NUMBER,
      pcramo IN VARCHAR2,
      ptcompania IN VARCHAR2,
      pcvalor IN VARCHAR2,
      ptresultado IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    FUNCTION f_get_datsarlatf(
     pssarlaft IN NUMBER,
     pfradica IN DATE,
     psperson IN NUMBER,
     mensajes IN OUT t_iax_mensajes)
     RETURN sys_refcursor;
     /*************************************************************************
     FUNCTION f_get_tipiva
     Funcion que dado una PERSONA y una fecha retorna el % tipo de iva a la fecha
     que se emite una p?liza.
     param in psperson   : Codigo sperson
     param in pfecha     : Fecha en activo
     return              : % Tipo de iva a aplicar
     Autor               : JVG 24/10/2017
    *************************************************************************/
   FUNCTION f_get_tipiva(psperson IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

    FUNCTION f_set_cpep_sarlatf(
      PSSARLAFT   IN  NUMBER ,
      PIDENTIFICACION IN  NUMBER,
      PCTIPREL    IN  NUMBER,
      PTNOMBRE    IN   VARCHAR2,
      PCTIPIDEN   IN NUMBER ,
      PNNUMIDE    IN   VARCHAR2,
      PCPAIS      IN     NUMBER,
      PTPAIS      IN VARCHAR2,
      PTENTIDAD   IN VARCHAR2,
      PTCARGO     IN   VARCHAR2,
      PFDESVIN    IN   DATE
    ) RETURN NUMBER;

    FUNCTION f_get_cpep_sarlatf(
      PSSARLAFT   IN  NUMBER
    ) RETURN sys_refcursor;

    FUNCTION f_del_cpep_sarlatf(
      PSSARLAFT      IN  NUMBER ,
      PIDENTIFICACION IN NUMBER
    ) RETURN NUMBER;


    FUNCTION f_set_caccionista_sarlatf  (
      PSSARLAFT   IN  NUMBER ,
      PIDENTIFICACION IN  NUMBER,
      PPPARTICI   IN  NUMBER,
      PTNOMBRE    IN   VARCHAR2,
      PCTIPIDEN   IN NUMBER ,
      PNNUMIDE    IN   VARCHAR2 ,
      PCBOLSA     IN  NUMBER,
      PCPEP       IN NUMBER,
      PCTRIBUEXT  IN     NUMBER
    ) RETURN NUMBER;

    FUNCTION f_get_caccionista_sarlatf   (
      PSSARLAFT   IN  NUMBER
    )  RETURN sys_refcursor;

    FUNCTION f_del_caccionista_sarlatf   (
      PSSARLAFT      IN  NUMBER ,
      PIDENTIFICACION IN NUMBER
    )  RETURN NUMBER;


    FUNCTION f_set_accionista_sarlatf (
      PSSARLAFT       IN  NUMBER,
      PIDENTIFICACION IN  NUMBER,
      PPPARTICI       IN  NUMBER,
      PTNOMBRE        IN  VARCHAR2,
      PCTIPIDEN       IN  NUMBER,
      PNNUMIDE        IN  VARCHAR2,
      PTSOCIEDAD      IN  VARCHAR2,
      PNNUMIDESOC     IN  VARCHAR2
    )  RETURN NUMBER;

    FUNCTION f_get_accionista_sarlatf (
      PSSARLAFT   IN  NUMBER
    ) RETURN sys_refcursor;

    FUNCTION f_del_accionista_sarlatf (
      PSSARLAFT       IN  NUMBER ,
      PIDENTIFICACION IN NUMBER
    ) RETURN NUMBER;

    FUNCTION f_get_ultimosestados_sarlatf (
      PSPERSON   IN  NUMBER
    ) RETURN sys_refcursor;

  FUNCTION f_get_persona_sarlaf(
   psperson IN NUMBER,
     mensajes IN OUT t_iax_mensajes
  ) RETURN sys_refcursor;
  --INI--WAJ
    PROCEDURE p_del_impuesto(
      psperson IN number,
      pctipind IN number,
      errores OUT t_ob_error);
 --FIN--WAJ
  --  
  -- Inicio IAXIS-3287 01/04/2019
  /*************************************************************************
  FUNCTION f_duplicar_sarlaft
  Permite duplicar un formulario SARLAFT ya confirmado
  param in  pssarlaft     : Código Sarlaft
  param out pssarlaftdest : Nuevo Sarlaft
  param out mensajes   : mesajes de error
  return               : number
  *************************************************************************/
  FUNCTION f_duplicar_sarlaft (
    pssarlaft     IN  NUMBER,
    pssarlaftdest OUT NUMBER,
    mensajes      OUT t_iax_mensajes
   ) RETURN NUMBER;
   -- Fin IAXIS-3287 01/04/2019
   
   
   /*************************************************************************
	For IAXIS-4149 by PK-18/07/2019
	FUNCTION F_GET_CODITIPOBANC : Nueva funcion para obtener tipo de CUENTA.
		PCBANCO Código de Banco.
		PCTIPCC Que tipo de cuenta és.
	return              : 0 si ha ido bien, 1 si ha ido mal.
	*************************************************************************/
	FUNCTION F_GET_CODITIPOBANC(PCBANCO IN NUMBER, PCTIPCC IN VARCHAR2, PCTIPBAN OUT NUMBER)
      RETURN NUMBER;
    
 PROCEDURE P_PAGADOR_ALT(PI_SSEGURO IN NUMBER);
	
END pac_persona;

/

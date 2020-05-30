--------------------------------------------------------
--  DDL for Package Body PAC_IAX_SIN_RESCATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_SIN_RESCATES" AS
/*****************************************************************************
   NAME:       PAC_IAX_SIN_RESCATES
   PURPOSE:    Funciones de rescates para productos financieros

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/03/2008   JRH             1. Creación del package.
   2.0        20/05/2010   RSC             2. 0013829: APRB78 - Parametrizacion y adapatacion de rescastes
   3.0        01/07/2011   APD             3. 0018913: CRE998 - Afegir motiu de Rescats
   4.0        28/02/2012   RSC             4. 0020665: LCOL_T001-LCOL - UAT - TEC - Rescates
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;

   ------- Funciones internes

   --JRH 03/2008
     /*************************************************************************
      Valida si se puede realizar el rescate
      param in psseguro  : póliza
      param in pnriesgo  : riesgo
      param in pfecha     : fecha del rescate
      param in pccausin  : tipo oper ( 4 --> rescate total)
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valida_permite_rescate(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pccausin IN NUMBER,
      pimporte IN NUMBER,
      pfondosinfo IN t_iax_info,
      pctipcal IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pfecha= ' || pfecha
            || ' pccausin= ' || pccausin || ' pccausin= ' || pccausin;
      vobject        VARCHAR2(200) := 'PAC_IAX_SIN_RESCATES.f_valida_permite_rescate';
      v_sproduc      NUMBER;
      v_norden       NUMBER;
      num            NUMBER;
      pfondos        t_iax_datos_fnd;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR pccausin IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfondosinfo IS NOT NULL THEN
         IF pfondosinfo.COUNT > 0 THEN
            pfondos := t_iax_datos_fnd();

            FOR i IN pfondosinfo.FIRST .. pfondosinfo.LAST LOOP
               pfondos.EXTEND;
               pfondos(pfondos.LAST) := ob_iax_datos_fnd();
               pfondos(pfondos.LAST).ccesta := pfondosinfo(i).nombre_columna;
               pfondos(pfondos.LAST).cobliga := 1;

               IF pctipcal = 0 THEN
                  pfondos(pfondos.LAST).prescat := pfondosinfo(i).valor_columna;

                  IF (TO_NUMBER(pfondosinfo(i).valor_columna) > 100
                      OR TO_NUMBER(pfondosinfo(i).valor_columna) < 0) THEN
                     pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 9904942, vpasexec,
                                                       vparam);
                     RETURN 1;
                  END IF;
               ELSE
                  pfondos(pfondos.LAST).irescat := pfondosinfo(i).valor_columna;
               END IF;
            END LOOP;
         END IF;
      END IF;

      numerr := pac_md_sin_rescates.f_valida_permite_rescate(psseguro, pnriesgo, pfecha,
                                                             pccausin, pimporte, pfondos,
                                                             pctipcal, mensajes);

      IF numerr <> 0 THEN
          --PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr); -- el producto no permite rescates
         --RETURN 1;

         -- Bug 20665 - RSC - 28/02/2012 - LCOL_T001-LCOL - UAT - TEC - Rescates
         --RAISE e_object_error;
         RETURN 1;
      -- Fin Bug 20665
      END IF;

      --validar importes fondos.
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN NO_DATA_FOUND THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180602);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_valida_permite_rescate;

   --JRH 03/2008

   --JRH 03/2008
   /*************************************************************************
       Valida y realiza un rescate
       param in psseguro  : póliza
       param in pnriesgo  : riesgo
       param in pfecha     : pfecha del rescate
       pimporte           : Importe del rescate (nulo si es total)
       tipoOper           : 3 en rescate total , 4 en rescate parcial.
       param out mensajes : mensajes de error
       return             : 0 todo correcto
                            1 ha habido un error
    *************************************************************************/
   FUNCTION f_rescate_poliza(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pimporte IN NUMBER,
      pipenali IN sin_tramita_reserva.ipenali%TYPE,
      tipooper IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL,
      pcmotresc IN NUMBER DEFAULT NULL,
      pfondosinfo IN t_iax_info,
      pctipcal IN NUMBER)   -- Bug 18913 - APD - 01/07/2011
      RETURN NUMBER IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pfecha= ' || pfecha
            || ' pimporte= ' || pimporte || ' tipoOper= ' || tipooper;
      vobject        VARCHAR2(200) := 'PAC_IAX_SIN_RESCATES.f_rescate_poliza';
      reg_seg        seguros%ROWTYPE;
      v_norden       NUMBER;
      pfondos        t_iax_datos_fnd;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR tipooper IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfondosinfo IS NOT NULL THEN
         IF pfondosinfo.COUNT > 0 THEN
            pfondos := t_iax_datos_fnd();

            FOR i IN pfondosinfo.FIRST .. pfondosinfo.LAST LOOP
               pfondos.EXTEND;
               pfondos(pfondos.LAST) := ob_iax_datos_fnd();
               pfondos(pfondos.LAST).ccesta := pfondosinfo(i).nombre_columna;
               pfondos(pfondos.LAST).cobliga := 1;

               IF pctipcal = 0 THEN
                  pfondos(pfondos.LAST).prescat := pfondosinfo(i).valor_columna;
               ELSE
                  pfondos(pfondos.LAST).irescat := pfondosinfo(i).valor_columna;
               END IF;
            END LOOP;
         END IF;
      END IF;

      vpasexec := 2;
      -- Bug 18913 - APD - 01/07/2011 - se añade el parametro pcmotresc a la
      -- funcion pac_md_sin_rescates.f_rescate_poliza
      numerr := pac_md_sin_rescates.f_rescate_poliza(psseguro, pnriesgo, pfecha,
                                                     TO_NUMBER(TO_CHAR(pimporte)), pipenali,
                                                     tipooper, mensajes, pimprcm, ppctreten,
                                                     pcmotresc, pfondos, pctipcal);

      -- Fin Bug 18913 - APD - 01/07/2011
      IF numerr <> 0 THEN
         --PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr); -- el producto no permite rescates
         --RAISE e_object_error;
         RETURN 1;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 111313);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_rescate_poliza;

   --JRH 03/2008

   --JRH 03/2008
   /*************************************************************************
      Valida y realiza la simulación de un rescate
      param in psseguro  : póliza
      param in pnriesgo  : riesgo
      param in pfecha     : pfecha del rescate
      pimporte           : Importe del rescate (nulo si es total)
      pccausin           : 4 en rescate total , 5 en rescate parcial.
      param out mensajes : mensajes de error
      return             : 0 todo correcto
                           1 ha habido un error
   *************************************************************************/
   FUNCTION f_valor_simulacion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfecha IN DATE,
      pimporte IN NUMBER,
      pccausin IN NUMBER,
      pctipcal IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pimppenali IN NUMBER DEFAULT NULL,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL)   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      RETURN ob_iax_simrescate IS
      numerr         NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psproduc= ' || psseguro || ' pnriesgo= ' || pnriesgo || ' pfecha= ' || pfecha
            || ' pimporte= ' || pimporte || ' pccausin= ' || pccausin;
      vobject        VARCHAR2(200) := 'PAC_IAX_SIN_RESCATES.f_Valor_Simulacion';
      num_err        NUMBER;
      w_cgarant      NUMBER;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      ximport        NUMBER;
      mostrar_datos  NUMBER;
      cavis          NUMBER;
      simresc        ob_iax_simrescate;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pfecha IS NULL
         OR pccausin IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      vpasexec := 2;
      numerr := pac_md_sin_rescates.f_valor_simulacion(psseguro, pnriesgo, pfecha, pimporte,
                                                       pccausin, pctipcal, simresc, mensajes,
                                                       pimppenali, pimprcm, ppctreten);

      IF numerr <> 0 THEN
         RAISE e_object_error;
         --PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr); -- el producto no permite rescates
         RETURN NULL;
      END IF;

      RETURN simresc;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_valor_simulacion;
--JRH 03/2008
END pac_iax_sin_rescates;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_RESCATES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_RESCATES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_RESCATES" TO "PROGRAMADORESCSI";

--------------------------------------------------------
--  DDL for Package Body PAC_MD_TRASPASOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_TRASPASOS" AS
   /******************************************************************************
     NOMBRE:       PAC_MD_traspasos
     PROPÓSITO:  Package para gestionar los traspasosS

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        06/05/2009   ICV                1. Creación del package. Bug.: 9940
     2.0        29/06/2010   PFA                2. 15197: CEM210 - La data 'Fecha antigüedad' no es recupera correctament de la taula
     3.0        06/10/2010   SRA                3. 0016215: ANUL·LACIÓ TRASPASSOS
     4.0        18/10/2010   SRA                4. 0016259: HABILITAR CAMPOS DE TEXTO ESPECÍFICOS PARA TRASPASOS DERECHOS ECONÓMICOS
     5.0        18/05/2011   RSC                5. 0018581: Trapassos de sortida PPA
     6.0        25/06/2013   RCL                6. 0024697: Canvi mida camp sseguro
     7.0        07/10/2013   JMG                7. 0028462-155008 : Modificación de campos clave que actualmente estan definidos
                                                 en la base de datos como NUMBER(X) para dejarlos como NUMBER
   ******************************************************************************/
   /*************************************************************************
          FUNCTION f_get_dattraspasos
          Función para devolver los campos descriptivos de un traspasos.
          param in Ptraspasos: Tipo carácter. Id. del traspasos.
          param out MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error
          return             : Retorna un sys_refcursor con los campos descriptivos de un traspasos.
      *************************************************************************/
   /*************************************************************************
   FUNCTION f_get_ccompani_dgs
   Función que sirve para recuperar el codigo_DGS de la compañía.
        PCCOMPANI: Tipo numérico. Parámetro de entrada. Código de compañía
        PTCOMPANI_DGS: Tipo varchar2. Parámetro de salida. Código de DGS compañía
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna un NUMBER 0 OK, 1 KO
    *************************************************************************/
   FUNCTION f_get_ccompani_dgs(
      pccompani IN NUMBER,
      pccompani_dgs OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vsperson       NUMBER(10);
      vparam         VARCHAR2(2000) := 'parámetros - pccompani= ' || pccompani;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.f_get_ccompani_dgs';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccompani IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT coddgs
        INTO pccompani_dgs
        FROM aseguradoras
       WHERE ccodaseg = pccompani;

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
   END f_get_ccompani_dgs;

   /*************************************************************************
   FUNCTION f_get_ccodpla_dgs
   Función que sirve para recuperar el codigo_DGS de la compañía.
        PCCODPLA: Tipo numérico. Parámetro de entrada. Código de compañía
        PTCODPLA_DGS: Tipo varchar2. Parámetro de salida. Código de DGS plan
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna un NUMBER 0 OK, 1 KO
    *************************************************************************/
   FUNCTION f_get_ccodpla_dgs(
      pccodpla IN NUMBER,
      pccodpla_dgs OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vsperson       NUMBER(10);
      vparam         VARCHAR2(2000) := 'parámetros - pccodpla= ' || pccodpla;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos. f_get_ccodpla_dgs';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodpla IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT coddgs
        INTO pccodpla_dgs
        FROM planpensiones
       WHERE ccodpla = pccodpla;

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
   END f_get_ccodpla_dgs;

      /*************************************************************************
      FUNCTION F_GET_TRASPASOS
      Función que sirve para recuperar una colección de traspasos.
           PSPRODUC: Tipo numérico. Parámetro de entrada. Código de producto.
           PFILTROPROD: Tipo carácter. Parámetro de entrada. Valor 'TRASPASO'.
           NPOLIZA: Tipo numérico. Parámetro de entrada. Id. de póliza.
           NCERTIF: Tipo numérico. Parámetro de entrada. Id. de certificado
           PNNUMNIDE: Tipo carácter. Parámetro de entrada. Documento.
           PBUSCAR: Tipo carácter. Parámetro de entrada. Nombre de la persona.
           PTIPOPERSONA: Tipo numérico. Parámetro de entrada. Indica si buscamos por Tomador o Asegurado
           PSNIP: Tipo carácter. Parámetro de entrada. Número d'identificador.
           PCINOUT: Tipo numérico. Parámetro de entrada. Traspasos de entrada o salida
           PCESTADO: Tipo numérico. Parámetro de entrada. Indica el estado.
           PFSOLICI: Tipo fecha. Parámetro de entrada. Fecha solicitud.
           PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total o Parcial
           PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Tipo importe Potser sobra o millor algun altre paràmetre com PCTIPDER.
           MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna una colección t_iax_traspasos.
       *************************************************************************/
   FUNCTION f_get_traspasos(
      psproduc IN NUMBER,   -- Código de producto
      cramo IN NUMBER,   -- Código de ramo
      pfiltroprod IN VARCHAR2,   -- Valor ‘TRASPASO’
      npoliza IN NUMBER,   -- Id  de póliza
      ncertif IN NUMBER,   -- Id  de certificado
      pnnumnide IN VARCHAR2,   -- Documento
      pbuscar IN VARCHAR2,   -- Nombre de la persona
      ptipopersona IN NUMBER,   -- Indica si buscamos por Tomador o Asegurado
      psnip IN VARCHAR2,   -- Número d’identificador
      pcinout IN NUMBER,   -- Traspasos de entrada o salida
      pcestado IN NUMBER,   -- Indica el estado
      pfsolici IN DATE,   -- Fecha solicitud
      pctiptras IN NUMBER,   -- Total o Parcial
      pctiptrassol IN NUMBER,   -- Tipo importe
      pmodo IN VARCHAR2,   -- Mode amb que es entra a fer traspasos (Anulacio, revocació, solicitud...)
      mensajes IN OUT t_iax_mensajes)   -- Mensaje de error
      RETURN t_iax_traspasos IS
      v_result       t_iax_traspasos := t_iax_traspasos();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - psproduc:' || TO_CHAR(psproduc) || 'pfiltroprod:' || pfiltroprod
            || 'npoliza:' || TO_CHAR(npoliza) || 'ncertif:' || TO_CHAR(ncertif)
            || 'pnnumnide:' || pnnumnide;   --Solo los obligatorios
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_GET_TRASPASOS';
      v_fich         VARCHAR2(400);
      v_error        NUMBER;
      vtraspas       sys_refcursor;
      traspaso       ob_iax_traspasos := ob_iax_traspasos();
   BEGIN
      vpasexec := 1;
      --Comprovem els parametres d'entrada.
      vpasexec := 2;
      vtraspas := pac_traspasos.f_get_traspasos(psproduc, cramo, pfiltroprod, npoliza,
                                                ncertif, pnnumnide, pbuscar, ptipopersona,
                                                psnip, pcinout, pcestado, pfsolici, pctiptras,
                                                pctiptrassol, pmodo, v_error);

      LOOP
         FETCH vtraspas
          INTO traspaso.stras, traspaso.sseguro, traspaso.nriesgo, traspaso.npoliza,
               traspaso.ncertif, traspaso.sproduc, traspaso.cagrpro, traspaso.sperstom,
               traspaso.nniftom, traspaso.tnomtom, traspaso.spersase, traspaso.nnifase,
               traspaso.tnomase, traspaso.fsolici, traspaso.cinout, traspaso.tcinout,
               traspaso.ctiptras, traspaso.tctiptras, traspaso.cextern, traspaso.textern,
               traspaso.ctipder, traspaso.tctipder, traspaso.cestado, traspaso.tcestado,
               traspaso.ctiptrassol, traspaso.tctiptrassol, traspaso.iimptemp,
               traspaso.nporcen, traspaso.nparpla, traspaso.iimporte, traspaso.fvalor,
               traspaso.fefecto, traspaso.nnumlin, traspaso.fcontab, traspaso.ccodpla,
               traspaso.tccodpla, traspaso.ccompani, traspaso.tcompani, traspaso.ctipban,
               traspaso.cbancar, traspaso.tpolext, traspaso.ncertext, traspaso.ssegext,

               --traspaso.planp,
               traspaso.fantigi, traspaso.iimpanu, traspaso.nparret, traspaso.iimpret,
               traspaso.nsinies, traspaso.nparpos2006, traspaso.porcpos2006,
               traspaso.nparant2007, traspaso.porcant2007, traspaso.tmemo, traspaso.srefc234,
               traspaso.cenvio, traspaso.tenvio
                                               --traspaso.tprest, traspaso.planaho;
         ;

--------------------------------------------
         EXIT WHEN vtraspas%NOTFOUND;
         v_result.EXTEND;
         v_result(v_result.LAST) := traspaso;
         traspaso := ob_iax_traspasos();
      END LOOP;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_get_traspasos;

   /*************************************************************************
   FUNCTION F_GET_TRASPASO
   Función que sirve para recuperar una colección de un traspaso.
        PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna una colección t_iax_traspasos con UN SOLO TRAPASO
    *************************************************************************/
   FUNCTION f_get_traspaso(pstras IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_traspasos IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.f_get_traspaso';
      v_fich         VARCHAR2(400);
      vtraspas       sys_refcursor;
      traspaso       ob_iax_traspasos := ob_iax_traspasos();
      v_numerr       NUMBER;
      -- Bug 16259 - SRA - 18/10/2010: variable para recuperar los datos de la prestación
      vpresta        sys_refcursor;
      prestacion     ob_iax_prestaciones := ob_iax_prestaciones();
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vtraspas := pac_traspasos.f_get_traspaso(pstras, v_numerr);

      LOOP
         FETCH vtraspas
          INTO traspaso.cbancar, traspaso.ccodpla_dgs, traspaso.tccodpla, traspaso.ccompani,
               traspaso.tcompani, traspaso.cestado, traspaso.cextern, traspaso.cinout,
               traspaso.ctipban, traspaso.ctipder, traspaso.ctiptras, traspaso.ctiptrassol,
               traspaso.fantigi, traspaso.fsolici, traspaso.fvalor, traspaso.iimpanu,
               traspaso.iimporte, traspaso.iimpret, traspaso.iimptemp, traspaso.ncertext,
               traspaso.nnumlin, traspaso.nparant2007, traspaso.nparpla, traspaso.nparpos2006,
               traspaso.nparret, traspaso.nporcen, traspaso.porcant2007, traspaso.porcpos2006,
               traspaso.nsinies, traspaso.sseguro, traspaso.stras, traspaso.tccodpla,
               traspaso.tmemo, traspaso.tpolext, traspaso.cagrpro, traspaso.sproduc,
               traspaso.srefc234, traspaso.cenvio, traspaso.ccodpla, traspaso.cmotivo,
               traspaso.fefecto,
                                -- Bug 16259 - SRA - 18/10/2010: recuperamos en la consulta los campos de "contingencia acaecida" y "fecha de contingencia"
                                traspaso.ctipcont, traspaso.fconting;

         -- obtengo la ccompani_DGS y CODPLA_DGS
         IF traspaso.ccodpla IS NOT NULL THEN
            v_numerr := f_get_ccodpla_dgs(traspaso.ccodpla, traspaso.ccodpla_dgs, mensajes);
         END IF;

         IF traspaso.ccompani IS NOT NULL THEN
            v_numerr := f_get_ccompani_dgs(traspaso.ccompani, traspaso.ccompani_dgs, mensajes);
         END IF;

         -- JGM - Añadir las funciones que calculan los otros campos de la variable TRASPASO
         EXIT WHEN vtraspas%NOTFOUND;
      /*v_result.EXTEND;
      v_result(v_result.LAST) := traspaso;
      traspaso := ob_iax_traspasos();*/
      END LOOP;

-- Bug 16259 - SRA - 18/10/2010: recuperamos los datos de la prestación y los guardamos junto al resto de información del traspaso
      vpasexec := 3;
      vpresta := pac_traspasos.f_get_trasplapresta(pstras, v_numerr);

      LOOP
         DECLARE
            vtrasplapresta trasplapresta%ROWTYPE;
         BEGIN
            vpasexec := 4;

            FETCH vpresta
             INTO prestacion.stras, vtrasplapresta.npresta, prestacion.sperson,
                  prestacion.ctipcap, vtrasplapresta.ctipimp, prestacion.importe,
                  vtrasplapresta.npartot, vtrasplapresta.impultab, vtrasplapresta.impminrf,
                  vtrasplapresta.indbenef, vtrasplapresta.indpos06, vtrasplapresta.porpos06,
                  prestacion.fpropag, vtrasplapresta.fultpag, vtrasplapresta.cperiod,
                  vtrasplapresta.creval, prestacion.ctiprev, prestacion.fprorev,
                  prestacion.prevalo, prestacion.irevalo, prestacion.nrevanu,
                  vtrasplapresta.cbancar, vtrasplapresta.ctipban, prestacion.nsinies;

            EXIT WHEN vpresta%NOTFOUND;
            vpasexec := 5;
            traspaso.tprest := prestacion;
         END;
      END LOOP;

      RETURN traspaso;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN traspaso;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN traspaso;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN traspaso;
   END f_get_traspaso;

/*************************************************************************
FUNCTION F_SET_TRASPASO
Función que sirve para insertar o actualizar datos del traspaso. Sólo se puede utilizar si el traspaso esta en estado Sin confirmar o Confirmado.

Retorna un valor numérico: 0 si ha grabado el traspaso y 1 si se ha producido algún error.
*************************************************************************/
   FUNCTION f_set_traspaso(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pcagrpro IN NUMBER,
      pfsolici IN DATE,
      pcinout IN NUMBER,
      pctiptras IN NUMBER,
      pcextern IN NUMBER,
      pctipder IN NUMBER,
      pcestado IN NUMBER,
      pctiptrassol IN NUMBER,
      piimptemp IN NUMBER,
      nporcen IN NUMBER,
      nparpla IN NUMBER,
      ccodpla IN NUMBER,
      tccodpla IN VARCHAR2,
      ccompani IN NUMBER,
      tcompani IN VARCHAR2,
      ctipban IN NUMBER,
      cbancar IN VARCHAR2,
      tpolext IN VARCHAR2,
      ncertext IN NUMBER,
      fantigi IN DATE,
      iimpanu IN NUMBER,
      nparret IN NUMBER,
      iimpret IN NUMBER,
      nparpos2006 IN NUMBER,
      porcpos2006 IN NUMBER,
      nparant2007 IN NUMBER,
      porcant2007 IN NUMBER,
      tmemo IN VARCHAR2,
      nref IN VARCHAR2,
      cmotivo IN NUMBER,
      fefecto IN DATE,
      fvalor IN DATE,
-- Ini Bug 16259 - SRA - 20/10/2010: nuevos campos en la pantalla axisctr093
      pctipcont IN NUMBER,
      pfcontig IN DATE,
      pctipcap IN NUMBER,
      pimporte IN NUMBER,
      pfpropag IN DATE,
-- Fin Bug 16259 - SRA - 20/10/2010
      pstras IN OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - psproduc:' || psproduc || 'psseguro:' || psseguro || 'npcagrpro:'
            || pcagrpro || 'pfsolici:' || TO_CHAR(pfsolici, 'dd/mm/yyyy') || 'pcinout:'
            || pcinout || ' ... y más';
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_SET_TRASPASO';
      v_fich         VARCHAR2(400);
      psseguro_ori_dest NUMBER;
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF psseguro IS NULL
         OR pfsolici IS NULL
         OR pcinout IS NULL
         OR pctiptras IS NULL
         OR pctipder IS NULL
         OR pcestado IS NULL
         OR(ccodpla IS NULL
            AND ccompani IS NULL)
         OR(pctiptras = 2
            AND pctiptrassol IS NULL)
         OR(pctiptras = 2
            AND piimptemp IS NULL
            AND nporcen IS NULL
            AND nparpla IS NULL) THEN
         RAISE e_param_error;
      END IF;

      IF NVL(pcextern, 0) <> 1 THEN
         BEGIN
            SELECT sseguro
              INTO psseguro_ori_dest
              FROM seguros
             WHERE npoliza = tpolext
               AND ncertif = NVL(ncertext, 0);
         EXCEPTION
            WHEN OTHERS THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 111360);
               RAISE e_param_error;
         END;
      END IF;

      vpasexec := 2;
      v_result := pac_traspasos.f_set_traspaso(psseguro, pfsolici, pcinout, pctiptras,
                                               NVL(pcextern, 0), pctipder, pcestado,
                                               pctiptrassol, piimptemp, nporcen, nparpla,
                                               ccodpla, tccodpla, ccompani, tcompani, ctipban,
                                               cbancar, tpolext, ncertext, fantigi, iimpanu,
                                               nparret, iimpret, nparpos2006, porcpos2006,
                                               nparant2007, porcant2007, tmemo, nref, cmotivo,
                                               fefecto, fvalor,
                                               -- Ini Bug 16259 - SRA - 20/10/2010: nuevos campos en la pantalla axisctr093
                                               pctipcont, pfcontig, pctipcap, pimporte,
                                               pfpropag,
                                               -- Fin Bug 16259 - SRA - 20/10/2010
                                               pstras);

      IF v_result = 0
         AND pcinout = 1
         AND NVL(pcextern, 0) = 1 THEN
         v_result := pac_traspasos.f_enviar_traspaso(pstras);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_set_traspaso;

      /*************************************************************************
      FUNCTION F_DEL_TRASPASO
       Función que sirve para borrar los datos del traspaso. Sólo se puede utilizar
       si el traspaso esta en estado Sin confirmar. Y sólo se permite a un perfil de seguridad

       1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
       2.   MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha borrado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_del_traspaso(pstras IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.f_del_traspaso';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_traspasos.f_del_traspaso(pstras);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_del_traspaso;

      /*************************************************************************
      FUNCTION F_CONFIRMAR_TRASPASO
          Función que sirve para confirmar traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar.

           1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
           2.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha confirmado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_confirmar_traspaso(
      pstras IN NUMBER,
      pinout IN NUMBER,
      pextern IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_CONFIRMAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_traspasos.f_actest_traspaso(pstras, 2, pinout, pextern, NULL);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_confirmar_traspaso;

   /*************************************************************************
   FUNCTION F_DESCONFIRMAR_TRASPASO
    Función que sirve para confirmar traspaso. Sólo se puede utilizar si el traspaso está en estado Confirmado.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

    Retorna un valor numérico: 0 si ha desconfirmado el traspaso y 1 si se ha producido algún error
    *************************************************************************/
   FUNCTION f_desconfirmar_traspaso(pstras IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_DESCONFIRMAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_traspasos.f_actest_traspaso(pstras, 1, NULL, NULL, NULL);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_desconfirmar_traspaso;

      /*************************************************************************
      FUNCTION F_DEMORAR_TRASPASO
       Función que sirve para demorar un traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar.

           1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
           2.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha demorado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_demorar_traspaso(
      pstras IN NUMBER,
      pinout IN NUMBER,
      pextern IN NUMBER,
      cmotivo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_DEMORAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL
         OR cmotivo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_traspasos.f_actest_traspaso(pstras, 8, pinout, pextern, cmotivo);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_demorar_traspaso;

      /*************************************************************************
      FUNCTION F_RECHAZAR_TRASPASO
       Función que sirve para rechazar un traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar, Confirmado o en Demora.

       1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
       2.   MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha rechazado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_rechazar_traspaso(
      pstras IN NUMBER,
      pinout IN NUMBER,
      pextern IN NUMBER,
      cmotivo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_RECHAZAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL
         OR cmotivo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_traspasos.f_actest_traspaso(pstras, 6, pinout, pextern, cmotivo);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_rechazar_traspaso;

   /*************************************************************************
   FUNCTION F_ANULAR_TRASPASO
    Función que sirve para anular un traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar, Confirmado o en Demora

    1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
    2.   MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

    Retorna un valor numérico: 0 si ha borrado el traspaso y 1 si se ha producido algún error

    *************************************************************************/
   FUNCTION f_anular_traspaso(
      pstras IN NUMBER,
      cmotivo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_ANULAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL
                       -- BUG 16215 - 06/10/2010 - SRA - se elimina la obligatoriedad de informar un motivo de anulación del traspaso
                        /*OR cmotivo IS NULL*/
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- BUG 16215 - 06/10/2010 - SRA - como motivo de la anulación se pasará el valor fijo 49 (ver listas de valores 332)
      v_result := pac_traspasos.f_actest_traspaso(pstras, 5, NULL, NULL, /*cmotivo*/ 49);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_anular_traspaso;

      /*************************************************************************
   FUNCTION F_ENVIAR_TRASPASO
       Función que sirve para enviar un traspaso con la norma 234.

         1. PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.

    Retorna un valor numérico: 0 si ha grabado el traspaso y un código identificativo de error si se ha producido algún problema.
    *************************************************************************/
   FUNCTION f_enviar_traspaso(pstras IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pstras = ' || pstras;
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_ANULAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_traspasos.f_enviar_traspaso(pstras);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_enviar_traspaso;

   /*************************************************************************
    FUNCTION F_INFORMAR_TRASPASO
       Función que sirve para informar los datos fiscales (aportaciones del año, porcentaje aportaciones 2007, fecha de antigüedad …).
       Sólo se puede utilizar si el traspaso está en estado 3-Pendientes de informar.

    Retorna un valor numérico: 0 si ha informado el traspaso y 1 si se ha producido algún error.
    *************************************************************************/
   FUNCTION f_informar_traspaso(
      pstras IN NUMBER,
      fantigi IN DATE,
      iimpanu IN NUMBER,
      nparret IN NUMBER,
      iimpret IN NUMBER,
      tmemo IN VARCHAR2,   -- BUG 15197 - PFA - Afegir camp observacions
      nparpos2006 IN NUMBER,
      porcpos2006 IN NUMBER,
      nparant2007 IN NUMBER,
      porcant2007 IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pstras = ' || pstras || ' fantigi = '
            || TO_CHAR(fantigi, 'dd/mm/yyyy') || ' iimpanu = ' || iimpanu;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_INFORMAR_TRASPASO';
      v_fich         VARCHAR2(400);
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_traspasos.f_informar_traspaso(pstras, fantigi, iimpanu, nparret, iimpret,
                                                    tmemo, nparpos2006, porcpos2006,
                                                    nparant2007, porcant2007);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_informar_traspaso;

/*************************************************************************
    FUNCTION F_EJECUTAR_TRASPASO
       Función que sirve para ejecutar un traspaso. Sólo se puede utilizar si el traspaso está en estado Confirmado.

    Retorna un valor numérico: 0 si ha ejecutado el traspaso y 1 si se ha producido algún error.
*************************************************************************/
   FUNCTION f_ejecutar_traspaso(
      pstras IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcagrpro IN NUMBER,
      pcinout IN NUMBER,
      pctiptras IN NUMBER,
      pcextern IN NUMBER,
      pctipder IN NUMBER,
      pctiptrassol IN NUMBER,
      piimptemp IN NUMBER,
      nporcen IN NUMBER,
      nparpla IN NUMBER,
      ccodpla IN NUMBER,
      ccompani IN NUMBER,
      ctipban IN NUMBER,
      cbancar IN VARCHAR2,
      tpolext IN VARCHAR2,
      ncertext IN NUMBER,
      pfefecto IN DATE,
      pfvalmov IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1000;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pstras = ' || pstras || ' psseguro = ' || psseguro || ' pnriesgo = '
            || pnriesgo || ' pcagrpro= ' || pcagrpro;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_EJECUTAR_TRASPASO';
      pimovimi       trasplainout.iimptemp%TYPE;
      ppartras       trasplainout.nparpla%TYPE;
      pnporcen       trasplainout.nporcen%TYPE;
      pporcdcons     NUMBER(10, 5);
      pporcdecon     NUMBER(10, 5);
      psseguro_ori_dest seguros.sseguro%TYPE;
      psproces       NUMBER;   -- Bug 28462 - 08/10/2013 - JMG - Modificacion campo sproces a NUMBER
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pstras IS NULL
         OR psseguro IS NULL
         OR pnriesgo IS NULL
         OR pcagrpro IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Si es entrada, extern i no han informat un import definitiu
      IF pcinout = 1
         AND pcextern = 1
         AND NVL(piimptemp, 0) = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901039);
         RETURN v_result;
      END IF;

      DECLARE
         xestado        NUMBER(2);
      BEGIN
         SELECT cestado
           INTO xestado
           FROM trasplainout
          WHERE stras = pstras;

         IF xestado <> 2 THEN
            RAISE e_param_error;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_param_error;
      END;

      IF NVL(pcextern, 0) <> 1 THEN
         BEGIN
            -- Bug 18581 - RSC - 18/05/2011 - Trapassos de sortida PPA (Afegim el NVL)
            SELECT sseguro
              INTO psseguro_ori_dest
              FROM seguros
             WHERE npoliza = tpolext
               AND ncertif = NVL(ncertext, 0);
         -- Fin Bug 18581
         EXCEPTION
            WHEN OTHERS THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 111360);
               RAISE e_param_error;
         END;
      END IF;

      vpasexec := 2;
      pimovimi := piimptemp;
      ppartras := nparpla;
      pnporcen := nporcen;

      IF pcinout = 1 THEN   ---- Entrada
         --define variable -
         vpasexec := 3;
         v_result := pac_traspasos.f_in_partic(pstras, pctiptras, psseguro, pcagrpro,
                                               pfvalmov, pfefecto, pimovimi, ppartras,
                                               pnporcen, pctiptrassol, NVL(pcextern, 0),
                                               psseguro_ori_dest, 1, pporcdcons, pporcdecon,
                                               psproces, pctipder);
         vpasexec := v_result;
      ELSIF pcinout = 2 THEN   ---- Salida
         vpasexec := 5;
         v_result := pac_traspasos.f_out_partic(pstras, pctiptras, psseguro, pcagrpro,
                                                pfvalmov, pfefecto, pimovimi, ppartras,
                                                pnporcen, pctiptrassol, NVL(pcextern, 0),
                                                psseguro_ori_dest, 1, pporcdcons, pporcdecon,
                                                psproces, pctipder);
         vpasexec := v_result;
      END IF;

      IF v_result = 0
         AND pcinout = 2
         AND NVL(pcextern, 0) = 1 THEN
         vpasexec := 7;
         v_result := pac_traspasos.f_enviar_traspaso(pstras);
         vpasexec := v_result;
      END IF;

      ---CONTROL DE ERRORES -----
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_ejecutar_traspaso;

   /*************************************************************************
   FUNCTION F_GET_COMPAÑIA
   Función que sirve para recuperar un nombre de compania a traves de DGS
        PCCOMPANI: Tipo numérico. Parámetro de entrada. Código de DGS compañía
        PTCOMPANI: Tipo varchar2. Parámetro de salida. Nombre de la compañía
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna un NUMBER 0 OK, 1 KO
    *************************************************************************/
   FUNCTION f_get_tcompani(
      pccompani_dgs IN VARCHAR2,
      pccompani IN OUT VARCHAR2,
      ptcompani IN OUT VARCHAR2,
      pctipban IN OUT NUMBER,
      pcbancar IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vsperson       NUMBER(10);
      vparam         VARCHAR2(2000) := 'parámetros - pccompani= ' || pccompani;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.f_get_tcompani';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccompani_dgs IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT a.sperson, a.ccodaseg, rel.ctipban,
             pac_cbancar_seg.ff_formatccc(rel.ctipban, rel.cbancar)
        INTO vsperson, pccompani, pctipban,
             pcbancar
        FROM aseguradoras a, relasegdep rel
       WHERE a.ccodaseg = rel.ccodaseg(+)
         AND rel.ctrasp(+) = 1
         AND a.coddgs = pccompani_dgs;

      ptcompani := f_nombre(vsperson, 1);
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9900958);   -- el producto no permite rescates
         RETURN 1;
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
   END f_get_tcompani;

   /*************************************************************************
   FUNCTION f_get_ccodpla
   Función que sirve para recuperar el codigo del plan a traves del codigo DGS
        PCCODPLA_DGS: Tipo varchar2. Parámetro de salida. Código de DGS plan
        PCCODPLA: Tipo numérico. Parámetro de entrada. Código de compañía
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna un NUMBER 0 OK, 1 KO
    *************************************************************************/
   FUNCTION f_get_ccodpla(
      pccodpla_dgs IN VARCHAR2,
      pccodpla IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vsperson       NUMBER(10);
      vparam         VARCHAR2(2000) := 'parámetros - pccodpla= ' || pccodpla;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos. f_get_ccodpla_dgs';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodpla_dgs IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT ccodpla
        INTO pccodpla
        FROM planpensiones
       WHERE coddgs = pccodpla_dgs;

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9900958);   -- el producto no permite rescates
         RETURN 1;
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
   END f_get_ccodpla;

   FUNCTION f_get_traspasos_pol(
      psseguro IN seguros.sseguro%TYPE,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_traspasos IS
      v_result       t_iax_traspasos := t_iax_traspasos();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                 := 'parámetros - psseguro:' || psseguro || ' pmodo:' || pmodo;
      vobject        VARCHAR2(200) := 'PAC_MD_traspasos.F_GET_TRASPASOS_POL';
      v_fich         VARCHAR2(400);
      v_error        NUMBER;
      vtraspas       sys_refcursor;
      traspaso       ob_iax_traspasos := ob_iax_traspasos();
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      BEGIN
         vpasexec := 2;
         vtraspas := pac_traspasos.f_get_traspasos_pol(psseguro, pmodo, v_error);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_object_error;
      END;

      LOOP
         FETCH vtraspas
          INTO traspaso.stras, traspaso.sseguro, traspaso.nriesgo, traspaso.npoliza,
               traspaso.ncertif, traspaso.sproduc, traspaso.cagrpro, traspaso.sperstom,
               traspaso.nniftom, traspaso.tnomtom, traspaso.spersase, traspaso.nnifase,
               traspaso.tnomase, traspaso.fsolici, traspaso.cinout, traspaso.tcinout,
               traspaso.ctiptras, traspaso.tctiptras, traspaso.cextern, traspaso.textern,
               traspaso.ctipder, traspaso.tctipder, traspaso.cestado, traspaso.tcestado,
               traspaso.ctiptrassol, traspaso.tctiptrassol, traspaso.iimptemp,
               traspaso.nporcen, traspaso.nparpla, traspaso.iimporte, traspaso.fvalor,
               traspaso.fefecto, traspaso.nnumlin, traspaso.fcontab, traspaso.ccodpla,
               traspaso.tccodpla, traspaso.ccompani, traspaso.tcompani, traspaso.ctipban,
               traspaso.cbancar, traspaso.tpolext, traspaso.ncertext, traspaso.ssegext,

               --traspaso.planp,
               traspaso.fantigi, traspaso.iimpanu, traspaso.nparret, traspaso.iimpret,
               traspaso.nsinies, traspaso.nparpos2006, traspaso.porcpos2006,
               traspaso.nparant2007, traspaso.porcant2007, traspaso.tmemo, traspaso.srefc234,
               traspaso.cenvio, traspaso.tenvio
                                               --traspaso.tprest, traspaso.planaho;
         ;

--------------------------------------------
         EXIT WHEN vtraspas%NOTFOUND;
         v_result.EXTEND;
         v_result(v_result.LAST) := traspaso;
         traspaso := ob_iax_traspasos();
      END LOOP;

      vpasexec := 4;
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_get_traspasos_pol;
END pac_md_traspasos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_TRASPASOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRASPASOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRASPASOS" TO "PROGRAMADORESCSI";

CREATE OR REPLACE PACKAGE BODY "PAC_GESTION_PROCESOS" AS
   /******************************************************************************
      NOMBRE:      pac_gestion_procesos
      PROP¿SITO: Funciones para la gesti¿n de la carga de procesos
      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        10/05/2010   XPL              1. Creaci¿n del package.
      2.0        04/06/2010   PFA              2. 14750: ENSA101 - Reproceso de procesos ya existentes
      3.0        11/10/2010   FAL              3. 0014888: CRT002 - Carga de polizas,recibos y siniestros Allianz
      4.0        18/10/2010   FAL              4. 0016324: CRT - Configuracion de las cargas
      5.0        29/10/2010   JBN              5. 0016432: CRT002 - Error en axisint001 - Volumen elevado de registros
      6.0        13/12/2010   JMF              6. 0016856 CEM - Escut Amortitzaci¿ proc¿s anual actualitzaci¿ de capitals
      7.0        18/01/2011   ICV              7. 0017155: CRT003 - Informar estado actualizacion compa¿ia
      8.0        23/07/2013   JGR              8. 0027690: LCOL_A003-El mensaje de error que se graba en la tablas de control de cargas, no aparecen bien algunos mensajes. QT-8414
      9.0        13/03/2019   Swapnil          9. Cambios para IAXIS-2015
   ******************************************************************************/

   /*************************************************************************
      funci¿n que graba en la cabecera del control de procesos
       param in psproces  : Num procesos de la carga
       param in ptfichero : Nombre fichero a cargar
       param in pfini     : Fecha inicio carga
       param in pffin     : Fecha fin carga
       param in pcestado  : Estado de la carga
       param in pcproceso : Codigo proceso
       param in pcerror   : Error de la carga (Slitera)
       return             : 0 todo ha sido correcto(
      psproces IN NUMBER,
      ptfichero IN VARCHAR2,
      pfini IN DATE,
      pffin IN DATE,
      pcestado IN NUMBER,
      pcproceso IN NUMBER,
      pcerror IN NUMBER,
      pterror IN VARCHAR2,
      pcbloqueo IN NUMBER DEFAULT 0)
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_cabecera(
      psproces IN NUMBER,
      ptfichero IN VARCHAR2,
      pfini IN DATE,
      pffin IN DATE,
      pcestado IN NUMBER,
      pcproceso IN NUMBER,
      pcerror IN NUMBER,
      pterror IN VARCHAR2,
      pcbloqueo IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      -- Bug 0016324. FAL. 18/10/2010
      PRAGMA AUTONOMOUS_TRANSACTION;
      -- Fi Bug 0016324
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_set_carga_ctrl_cabecera';
      vparam         VARCHAR2(4000)
         := 'par¿metros - psproces : ' || psproces || ',tfichero : ' || ptfichero
            || ',fini : ' || pfini || ',ffin : ' || pffin || ',cestado : ' || pcestado
            || ',cproceso : ' || pcproceso || ',pcerror : ' || pcerror || ',pcbloqueo : '
            || pcbloqueo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcbloqueo      int_carga_ctrl.cbloqueo%TYPE;
   BEGIN
      IF ptfichero IS NULL
         --OR pfini IS NULL         -- Bug 15490/88884 - FAL - 01/07/2011. Evitar tener que informar finicio proceso una vez hecho el insert.
         OR pcestado IS NULL THEN
         RETURN 1000005;
      END IF;

      IF psproces IS NULL THEN
         --Si es alta de momento nunca llegar¿ a nulo,
         --pero en el caso de que llegara a nulo aqu¿ se tendr¿a que buscar
         --un sproces nuevo.
         NULL;
      END IF;

      -- bloqueo de procesos
      IF pcbloqueo = 1 THEN   -- compruebo si el proceso ya esta bloquedo
         BEGIN
            SELECT cbloqueo
              INTO vcbloqueo
              FROM int_carga_ctrl
             WHERE sproces = psproces;

            IF vcbloqueo = 1 THEN   -- si el proceso ya esta bloqueado..
               RETURN 9905979;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
         END;
      END IF;

      -- Bug 15490/88884 - FAL - 01/07/2011. Evitar tener que informar finicio proceso una vez hecho el insert.
      IF pfini IS NULL THEN
         UPDATE int_carga_ctrl
            SET tfichero = ptfichero,
            /** Cambios para IAXIS-2015 : Start
                fini = NVL(pfini, fini),
             ** Cambios para IAXIS-2015 : End **/
                ffin = pffin,
                cestado = pcestado,
                cproceso = pcproceso,
                cerror = pcerror,
                terror = pterror,
                cbloqueo = NVL(pcbloqueo, 0)   -- terminado
          WHERE sproces = psproces;

         COMMIT;
         RETURN 0;
      END IF;

      -- Fi Bug 15490/88884
      BEGIN

         INSERT INTO int_carga_ctrl
                     (sproces, tfichero, fini, ffin, cestado, cerror, terror,
                      cproceso, cbloqueo)
              VALUES (psproces, ptfichero, pfini, pffin, pcestado, pcerror, pterror,
                      pcproceso, NVL(pcbloqueo, 0));

		 p_tab_error(f_sysdate, f_user,'BARTOLO_f_set_carga_ctrl_cabecera_INSERTAR',1,vparam, SQLERRM);

      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE int_carga_ctrl
               SET tfichero = ptfichero,
            /** Cambios para IAXIS-2015 : Start
                   fini = NVL(pfini, fini),
             ** Cambios para IAXIS-2015 : End **/
                   ffin = pffin,
                   cestado = pcestado,
                   cproceso = pcproceso,
                   cerror = pcerror,
                   terror = pterror,
                   cbloqueo = NVL(pcbloqueo, 0)
             WHERE sproces = psproces;

       p_tab_error(f_sysdate, f_user,'BARTOLO_f_set_carga_ctrl_cabecera_MODIFICAR',1,vparam, SQLERRM);

      END;

      -- Bug 0016324. FAL. 18/10/2010
      COMMIT;
      -- Fi Bug 0016324
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'f_set_carga_ctrl_cabecera', SQLERRM);
         RETURN 1000006;
   END f_set_carga_ctrl_cabecera;

   /*************************************************************************
            funci¿n que graba en la linea que se esta tratando del fichero a cargar
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pctipo    : Tipo de registro (Poliza, Siniestro, Recibo, Persona)
       param in pidint    : Identificador interno visual
       param in pidext    : Identificador externo
       param in pcestado  : Estado de la linea
       param in pcvalidado: Linea validada
       param in psseguro  : Codigo del seguro en el caso que carguemos un seguro
       param in pnsinies  : Codigo del siniestros en el caso que carguemos un siniestro
       param in pntramit  : Codigo de la tramitaci¿n en el caso que carguemos un siniestro
       param in psperson  : Codigo de la persona en el caso que carguemos una persona
       param in pnrecibo  : Codigo del recibo en el caso que carguemos un recibo
       return             : 0 todo ha sido correcto
                            SLITERA ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_linea(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pctipo IN NUMBER,
      pidint IN VARCHAR2,
      pidext IN VARCHAR2,
      pcestado IN NUMBER,
      pcvalidado IN NUMBER,
      psseguro IN NUMBER,
      -- Bug 14888. FAL. 11/10/2010. A¿adir id. externo (npoliza,nsinies,nrecibo) de la compa¿ia
      pidexterno IN VARCHAR2,
      -- Fi Bug 14888
      -- Bug 16324. FAL. 26/10/2010. A¿adir ncarga (relacion con tablas mig)
      pncarga IN NUMBER,
      -- Fi Bug 16324
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      psperson IN NUMBER,
      pnrecibo IN NUMBER)
      RETURN NUMBER IS
      -- Bug 0016324. FAL. 18/10/2010
      PRAGMA AUTONOMOUS_TRANSACTION;
      -- Fi Bug 0016324
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_set_carga_ctrl_linea';
      -- INI IAXIS-3673 - JLTS - 23/04/2019 - Se incluye SUBSTR en pidint
      vparam         VARCHAR2(4000)
         := 'par¿metros - psproces : ' || psproces || ',pnlinea : ' || pnlinea || ',pctipo : '
            || pctipo || ',pidint : ' || SUBSTR(pidint,1,100) || ',pidext : ' || pidext || ',pcestado : '
            || pcestado || ',pcvalidado : ' || pcvalidado || ',psseguro : ' || psseguro
            || ',pnsinies : ' || pnsinies || ',pntramit : ' || pntramit || ',psperson : '
            || psperson || ',pnrecibo : ' || pnrecibo;
      -- FIN IAXIS-3673 - JLTS - 23/04/2019 - Se incluye SUBSTR en pidint
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnlinea        NUMBER;
   BEGIN
      IF psproces IS NULL
         OR pctipo IS NULL
         OR pidint IS NULL
         OR pcestado IS NULL THEN
         RETURN 1000005;
      END IF;

      vnlinea := pnlinea;

      IF pnlinea IS NULL THEN
         BEGIN
            SELECT NVL(MAX(NVL(nlinea, 0)), 0) + 1
              INTO vnlinea
              FROM int_carga_ctrl_linea
             WHERE sproces = psproces;
         EXCEPTION
            WHEN OTHERS THEN
               vnlinea := 1;
         END;
      END IF;

      BEGIN
         INSERT INTO int_carga_ctrl_linea
                     (sproces, nlinea, ctipo, idint, idext, cestado, cvalidado,
                      sseguro, nsinies, ntramit, sperson,
                      nrecibo,
                      tipoper,
                      ncarga)   -- Bug 16324. FAL. 26/10/2010. A¿adir ncarga (relacion con tablas mig)
              VALUES (psproces, vnlinea, pctipo, pidint,
                                                        -- Bug 14888. FAL. 11/10/2010. A¿adir id. externo (npoliza,nsinies,nrecibo) de la compa¿ia
                                                        pidexterno,   -- pidext,
                                                                   -- Fi Bug 14888
                                                                   pcestado, pcvalidado,
                      psseguro, pnsinies, pntramit, psperson,
                      pnrecibo   -- Bug 14888. FAL. 11/10/2010. A¿adir id. externo (npoliza,nsinies,nrecibo) de la compa¿ia
                              ,
                      pidext   -- Fi Bug 14888
                               -- Bug 16324. FAL. 26/10/2010. A¿adir ncarga (relacion con tablas mig)
                            ,
                      pncarga   -- Fi Bug 16324
                             );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE int_carga_ctrl_linea
               SET ctipo = pctipo,
                   idint = pidint,
                   -- Bug 14888. FAL. 11/10/2010. A¿adir id. externo (npoliza,nsinies,nrecibo) de la compa¿ia
                   idext = pidexterno,   --idext = pidext,
                   -- Fi Bug 14888
                   cestado = pcestado,
                   cvalidado = pcvalidado,
                   sseguro = psseguro,
                   nsinies = pnsinies,
                   ntramit = pntramit,
                   sperson = psperson,
                   nrecibo = pnrecibo,
                   -- Bug 14888. FAL. 11/10/2010. A¿adir id. externo (npoliza,nsinies,nrecibo) de la compa¿ia
                   tipoper = pidext,
                   -- Fi Bug 14888
                   -- Bug 16324. FAL. 26/10/2010. A¿adir ncarga (relacion con tablas mig)
                   ncarga = pncarga
             -- Fi Bug 16324
            WHERE  sproces = psproces
               AND nlinea = pnlinea;
      END;

      -- Bug 0016324. FAL. 18/10/2010
      COMMIT;
      -- Fi Bug 0016324
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'f_set_carga_ctrl_linea', SQLERRM);
         RETURN 1000006;
   END f_set_carga_ctrl_linea;

   /*************************************************************************
             funci¿n que graba el error de la linea del fichero que se esta cargando
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pnerror   : Num Error
       param in pctipo    : Tipo de error(warning, error, informativo)
       param in pcerror   : Codigo de error
       param in ptmensaje : Mensaje a mostrar
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_carga_ctrl_linea_error(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pnerror IN NUMBER,
      pctipo IN NUMBER,   --warning, error, informativo
      pcerror IN NUMBER,
      ptmensaje IN VARCHAR2)
      RETURN NUMBER IS
      -- Bug 0016324. FAL. 18/10/2010
      PRAGMA AUTONOMOUS_TRANSACTION;
      -- Fi Bug 0016324
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_set_carga_ctrl_linea_error';
      vparam         VARCHAR2(4000)
         := 'par¿metros - psproces : ' || psproces || ',pnlinea : ' || pnlinea
            || ',pnerror : ' || pnerror || ',pnerror : ' || pnerror || ',pctipo : ' || pctipo
            || ',pcerror : ' || pcerror || ',ptmensaje : ' || ptmensaje;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnerror        NUMBER;
   BEGIN
      IF psproces IS NULL
         OR pnlinea IS NULL
         OR pctipo IS NULL
         OR ptmensaje IS NULL THEN
         RETURN 1000005;
      END IF;

      vnerror := pnerror;

      IF pnerror IS NULL THEN
         BEGIN
            SELECT NVL(MAX(NVL(nerror, 0)), 0) + 1
              INTO vnerror
              FROM int_carga_ctrl_linea_errs
             WHERE sproces = psproces
               AND nlinea = pnlinea;
         EXCEPTION
            WHEN OTHERS THEN
               vnerror := 1;
         END;
      END IF;

      BEGIN
         INSERT INTO int_carga_ctrl_linea_errs
                     (sproces, nerror, nlinea, ctipo, cerror, tmensaje)
              VALUES (psproces, vnerror, pnlinea, pctipo, pcerror, ptmensaje);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE int_carga_ctrl_linea_errs
               SET ctipo = pctipo,
                   cerror = pcerror,
                   tmensaje = ptmensaje
             WHERE sproces = psproces
               AND nlinea = pnlinea
               AND nerror = pnerror;
      END;

      -- Bug 0016324. FAL. 18/10/2010
      COMMIT;
      -- Fi Bug 0016324
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'f_set_carga_ctrl_linea', SQLERRM);
         RETURN 1000006;
   END f_set_carga_ctrl_linea_error;

   /*************************************************************************
            funci¿n que recupera los registros de la cabecera de carga.
       param in psproces  : Num procesos de la carga
       param in ptfichero : Nombre fichero a cargar
       param in pfini     : Fecha inicio carga
       param in pffin     : Fecha fin carga
       param in pcestado  : Estado de la carga
       param in pcerror   : Error de la carga (Slitera)
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_cabecera(
      psproces IN NUMBER,
      ptfichero IN VARCHAR2,
      pfini IN DATE,
      pffin IN DATE,
      pcestado IN NUMBER,
      pcprocesos IN NUMBER,   -- BUG16432:JBN:29/10/2010
      pcempres IN NUMBER,   -- BUG16432:JBN:29/10/2010
      pcidioma IN NUMBER,
      pcrefext IN VARCHAR2,   -- BUG17045:LCF:12/01/2011
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_get_carga_ctrl_cabecera';
      vparam         VARCHAR2(4000)
         := 'par¿metros - psproces : ' || psproces || ',tfichero : ' || ptfichero
            || ',fini : ' || pfini || ',ffin : ' || pffin || ',cestado : ' || pcestado
            || ',pcprocesos : ' || pcprocesos;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vwhere         VARCHAR2(2000) := ' where f.cproceso(+) = icc.cproceso ';
      vresumen       VARCHAR2(1000);
      v_max_reg      NUMBER;
      vtfichero      VARCHAR2(1000);   -- BUG 38344/217178 - 29/10/2015 - ACL
      vcrefext       VARCHAR2(1000);   -- BUG 38344/217178 - 09/11/2015 - ACL
   BEGIN
      psquery := 'select icc.sproces,icc.tfichero,icc.fini,';

      --IF pcrefext IS NOT NULL THEN
      --   psquery := psquery || 'l.idext,';   -- a¿adimos el campo
      --END IF;

      --Bug 26050/142735 - 18/04/2013 - AMC
      IF psproces IS NOT NULL THEN
         vresumen := f_get_resumen_carga(psproces, pcidioma);
      END IF;

      -- Fi Bug 26050/142735 - 18/04/2013 - AMC
      psquery :=
         psquery || '(case when(icc.ffin is not null and icc.fini != icc.ffin)' || '      then'
         || '(case when (trunc((icc.ffin-icc.fini)*24,0)>0)'
         || '      then (trunc((icc.ffin-icc.fini)*24,0)||'' horas '')end||'
         || ' case when((to_char(icc.fini,''MI'')-to_char(icc.ffin,''MI''))>0)'
         || '      then(60-(to_char(icc.fini,''MI'')-to_char(icc.ffin,''MI'')))'
         || ' else(0-(to_char(icc.fini,''MI'')-to_char(icc.ffin,''MI'')))end||'' min'') '
         || ' else null end) as ffin,' || ' icc.cestado,ff_desvalorfijo(800019,' || pcidioma
         || ',icc.cestado) testado,' || ' icc.cerror, icc.cproceso, '
         -- 8. 0027690 - QT-8414 - Inicio
         --|| ' f_axis_literales(icc.cerror,' || pcidioma || ') cerror_lit,'
         || ' nvl(icc.terror, f_axis_literales(icc.cerror,' || pcidioma || ')) cerror_lit,'
         -- 8. 0027690 - QT-8414 - Final
         || ' icc.terror, f_axis_literales(f.cdescrip,' || pcidioma || ') cdescrip,'''
         || NVL(vresumen, 'null') || ''' resumcarga,'   --Bug 26050/142735 - 18/04/2013 - AMC
         || ' ff_desvalorfijo(8000924,' || pcidioma || ',icc.cbloqueo) tbloqueo '
         || ' from int_carga_ctrl icc, cfg_files f'   --Bug 14750-PFA-31/05/2010- A¿adir campo cproceso
         || ' , procesoscab x';   -- Bug 0016856 - 13/12/2010 - JMF

      --IF pcrefext IS NOT NULL THEN
      --   psquery := psquery || ', int_carga_ctrl_linea l';   -- a¿adimos la referencia
      --END IF;

      -- BUG16432:JBN:29/10/2010 A¿adir  cdescrip
      IF psproces IS NOT NULL THEN
         vwhere := vwhere || ' and icc.sproces = ' || psproces;
      END IF;

      IF ptfichero IS NOT NULL THEN
         -- Inicio BUG 38344/217178 - 29/10/2015 - ACL
         vtfichero := ptfichero;
         vtfichero := REPLACE(vtfichero, CHR(39), CHR(39) || CHR(39));
         vwhere := vwhere || ' and upper(icc.tfichero) like  upper(' || CHR(39) || '%'
                   || vtfichero || '%' || CHR(39) || ')';
      -- Fin BUG 38344/217178 - 29/10/2015 - ACL
      END IF;

      IF pfini IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(icc.fini) >= ' || CHR(39) || pfini || CHR(39);
      END IF;

      IF pcrefext IS NOT NULL THEN
         -- Inicio BUG 38344/217178 - 09/11/2015 - ACL
         vcrefext := pcrefext;
         vcrefext := REPLACE(vcrefext, CHR(39), CHR(39) || CHR(39));
         vwhere :=
            vwhere
            || 'AND exists(select 1 from int_carga_ctrl_linea l where l.SPROCES = icc.SPROCES and upper(l.idext) like upper('
            || CHR(39) || '%' || vcrefext || '%' || CHR(39) || '))';
      -- Fin BUG 38344/217178 - 09/11/2015 - ACL
      END IF;

      IF pffin IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(icc.fini) <= ' || CHR(39) || pffin || CHR(39);
      END IF;

      IF pcestado IS NOT NULL THEN
         vwhere := vwhere || ' and icc.cestado = ' || pcestado;
      END IF;

      -- BUG16432:JBN:29/10/2010:Inici
      IF pcprocesos IS NOT NULL THEN
         vwhere := vwhere || ' and icc.cproceso = ' || pcprocesos;
      END IF;

      -- Bug 0016856 - 13/12/2010 - JMF
      vwhere := vwhere || ' and x.sproces(+)=icc.sproces'
                || '  and (x.sproces is null or x.cempres=' || pcempres || ')';
      vwhere := vwhere || ' and f.cempres = ' || pcempres;
      -- BUG16432:JBN:29/10/2010:Fi

      -- Bug 26050/142735 - 18/04/2013 - AMC
      v_max_reg := pac_parametros.f_parinstalacion_n('N_MAX_REG');

      IF v_max_reg IS NOT NULL THEN
         vwhere := vwhere || ' and rownum <= ' || v_max_reg;
      END IF;

      -- Fi Bug 26050/142735 - 18/04/2013 - AMC
      vwhere := vwhere || ' order by sproces desc ';
      psquery := psquery || vwhere;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'f_get_carga_ctrl_cabecera', SQLERRM);
         RETURN 1000006;
   END f_get_carga_ctrl_cabecera;

   /*************************************************************************
            funci¿n que recupera los registros de la linea del proceso cargado
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_linea(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_get_carga_ctrl_linea';
      vparam         VARCHAR2(4000)
                         := 'par¿metros - psproces : ' || psproces || ',pnlinea : ' || pnlinea;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(2000);
      vwhere         VARCHAR2(2000) := ' where 1=1 ';
      vorder         VARCHAR2(2000) := ' order by nlinea asc ';
   BEGIN
      psquery :=
         'select sproces, nlinea, ctipo, ff_desvalorfijo(800018,' || pcidioma
         || ',ctipo)  ttipo, idint, idext, cestado, ff_desvalorfijo(800019,' || pcidioma
         || ',cestado)   testado, cvalidado, sseguro, ntramit,sperson,nrecibo,nsinies
    from int_carga_ctrl_linea ';

      IF psproces IS NOT NULL THEN
         vwhere := vwhere || ' and sproces = ' || psproces;
      END IF;

      IF pnlinea IS NOT NULL THEN
         vwhere := vwhere || ' and nlinea = ' || pnlinea;
      END IF;

      psquery := psquery || vwhere || vorder;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'f_get_carga_ctrl_linea', SQLERRM);
         RETURN 1000006;
   END f_get_carga_ctrl_linea;

   /*************************************************************************
             funci¿n que recupera los registros de los errores de la linea del proceso cargado
       param in psproces  : Num procesos de la carga
       param in pnlinea   : Num Linea
       param in pnerror   : Num Error
       param out          : mensajes de error
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_ctrl_linea_error(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pnerror IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_get_carga_ctrl_linea_error';
      vparam         VARCHAR2(4000)
         := 'par¿metros - psproces : ' || psproces || ',pnlinea : ' || pnlinea
            || ',pnerror : ' || pnerror;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vwhere         VARCHAR2(2000) := ' where 1=1 ';
   BEGIN
      psquery := 'select sproces, nlinea, nerror, ctipo,ff_desvalorfijo(800019,' || pcidioma
                 || ',ctipo)   ttipo, cerror, f_axis_literales(cerror,' || pcidioma
                 || ') terror, tmensaje
    from int_carga_ctrl_linea_errs ';

      IF psproces IS NOT NULL THEN
         vwhere := vwhere || ' and sproces = ' || psproces;
      END IF;

      IF pnlinea IS NOT NULL THEN
         vwhere := vwhere || ' and nlinea = ' || pnlinea;
      END IF;

      IF pnerror IS NOT NULL THEN
         vwhere := vwhere || ' and nerror = ' || pnerror;
      END IF;

      psquery := psquery || vwhere;
      --p_control_error('xpl', 'query 2', psquery);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'f_get_carga_ctrl_linea_error',
                     SQLERRM);
         RETURN 1000006;
   END f_get_carga_ctrl_linea_error;

   /*************************************************************************
               funci¿n que recupera los registros de la linea del proceso cargado
          param in psproces  : Num procesos de la carga
          param in pnlinea   : Num Linea
          param in pctipo    : Tipo de carga(Siniestros,polizas, personas, recibos...)
          param in pfini     : Fecha de inicio
          param in pffin     : Fecha de fin
          param in pvalor    : Valor segun tipo de carga(siniestros = nsinies, polizas = sseguro...)
          param in pidint    : Identificador interno
          param in pidext    : Identificador externo
          param in pcestado  : Estado de la linea
          param in pcrevisado : Linea revisada o no
          param out          : mensajes de error
          return             : 0 todo ha sido correcto
                               1 ha habido un error
      *************************************************************************/
   FUNCTION f_get_carga_ctrl_linea(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pctipo IN NUMBER,
      pfini IN DATE,
      pffin IN DATE,
      pvalor IN VARCHAR2,
      pidint IN VARCHAR2,
      pidext IN VARCHAR2,
      pcestado IN NUMBER,
      pcrevisado IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_get_carga_ctrl_linea';
      vparam         VARCHAR2(4000)
         := 'par¿metros - psproces : ' || psproces || ',pnlinea : ' || pnlinea || ',pctipo : '
            || pctipo || ',pfini : ' || pfini || ',pffin : ' || pffin || ',pvalor : '
            || pvalor || ',pidint : ' || pidint || ',pidext : ' || pidext || ',pcestado : '
            || pcestado || ',pcrevisado : ' || pcrevisado || ',pcidioma : ' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vquery         VARCHAR2(2000);
      vwhere         VARCHAR2(2000) := ' where 1=1 ';
      vnsinies       VARCHAR2(14);
      vnpoliza       NUMBER;
      vnrecibo       NUMBER;
      vsperson       NUMBER;
      v_max_reg      NUMBER := NULL;
   BEGIN
      psquery :=
         'select sproces, nlinea, ctipo, ff_desvalorfijo(800018,' || pcidioma
         || ',ctipo)  ttipo, idint, idext, cestado, ff_desvalorfijo(800019,' || pcidioma
         || ',cestado)   testado, cvalidado, sseguro, ntramit,sperson,nrecibo,nsinies
    from int_carga_ctrl_linea ';

      IF psproces IS NOT NULL THEN
         vwhere := vwhere || ' and sproces = ' || psproces;
      END IF;

      IF pnlinea IS NOT NULL THEN
         vwhere := vwhere || ' and nlinea = ' || pnlinea;
      END IF;

      IF pctipo IS NOT NULL THEN
         vwhere := vwhere || ' and ctipo  = ' || pctipo;

         IF pvalor IS NOT NULL THEN
            IF pctipo = 0 THEN
               vnpoliza := TO_NUMBER(pvalor);
               vwhere := vwhere
                         || ' and sseguro in select npoliza from seguros where npoliza = '
                         || vnpoliza;
            ELSIF pctipo = 1 THEN
               vnsinies := pvalor;
               vwhere := vwhere || ' and upper(nsinies) like  upper(' || vnsinies || ')';
            ELSIF pctipo = 2 THEN
               vnrecibo := TO_NUMBER(pvalor);
               vwhere := vwhere || ' and nrecibo = ' || vnrecibo;
            ELSIF pctipo = 3 THEN
               vsperson := TO_NUMBER(pvalor);
               vwhere := vwhere || ' and sperson  = ' || vsperson;
            END IF;
         END IF;
      END IF;

      IF pcestado IS NOT NULL THEN
         vwhere := vwhere || ' and cestado  = ' || pcestado;
      END IF;

      IF pcrevisado IS NOT NULL THEN
         vwhere := vwhere || ' and cvalidado  = ' || pcrevisado;
      END IF;

      IF pidint IS NOT NULL THEN
         vwhere := vwhere || ' and upper(idint) like upper(' || CHR(39) || '%' || pidint
                   || '%' || CHR(39) || ')';
      END IF;

      IF pidext IS NOT NULL THEN
         vwhere := vwhere || ' and upper(idext) like upper(' || CHR(39) || '%' || pidext
                   || '%' || CHR(39) || ')';
      END IF;

      IF pfini IS NOT NULL THEN
         vwhere :=
            vwhere
            || ' and trunc(fini in select sproces from int_carga_ctrl where sproces = psproces) = trunc('
            || pfini || ')';
      END IF;

      IF pffin IS NOT NULL THEN
         vwhere :=
            vwhere
            || ' and trunc(ffin in select sproces from int_carga_ctrl where sproces = psproces) = trunc('
            || pffin || ')';
      END IF;

      --Bug 14750-JBN-02/11/2010 Valor maxim de filas devueltas
      v_max_reg := pac_parametros.f_parinstalacion_n('N_MAX_REG_CTRL');
      --
      IF v_max_reg IS NOT NULL THEN
         vwhere := vwhere || ' and rownum <= ' || v_max_reg;
      ELSE
        v_max_reg := pac_parametros.f_parinstalacion_n('N_MAX_REG');
        IF v_max_reg IS NOT NULL THEN
           vwhere := vwhere || ' and rownum <= ' || v_max_reg;
        END IF;
      END IF;
      --
      vwhere := vwhere || ' order by sproces,nlinea asc ';
      psquery := psquery || vwhere;
      --p_control_error('xpl', 'query 1', psquery);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'f_get_carga_ctrl_linea', SQLERRM);
         RETURN 1000006;
   END f_get_carga_ctrl_linea;

   --Bug 14750-PFA-06/07/2010
   /*************************************************************************
         funci¿n que recupera los registros de la tabla intermedia correspondiente
       param in psproces  : Num proceso de la carga
       param in pcproceso : Identificador del proceso
       param in pnlinea   : Num Linea
       param out vtabla   : Informacion de la tabla
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_tabla_intermedia(
      psproces IN NUMBER,
      pcproceso IN NUMBER,
      pnlinea IN NUMBER,
      pcempres IN NUMBER,
      vtabla OUT VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_get_tabla_intermedia';
      vparam         VARCHAR2(4000)
         := 'par¿metros - psproces : ' || psproces || ',pcproceso : ' || pcproceso
            || ',pnlinea : ' || pnlinea || ',pcempres : ' || pcempres;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vwhere         VARCHAR2(2000) := ' where 1=1 ';
      vttabla        VARCHAR2(200);
   BEGIN
      SELECT ttabla
        INTO vtabla
        FROM cfg_files
       WHERE cempres = pcempres
         AND cproceso = pcproceso;

      /*
               pquery_info := ' SELECT * FROM ' || vttabla || 'where proceso = ' || psproces
                           || ' and nlinea = ' || pnlinea;
            pquery_columns := ' SELECT * FROM ALL_TAB_COLUMNS where table_name = ''' || vttabla || '';*/
      --p_control_error('xpl', 'query 2', psquery);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, 'f_get_tabla_intermedia', SQLERRM);
         RETURN 1000006;
   END f_get_tabla_intermedia;

--Fi Bug 14750-PFA-06/07/2010

   -- Bug 16432-JBN-09/11/2010
   /*************************************************************************
         funci¿n que modifica el estado de una linea
       param in psproces  : Num proceso de la carga
       param in pcestado :  Nuevo estado a modificar
       param in pnlinea   : Num Linea
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_cestado_lineaproceso(
      psproces IN NUMBER,
      pnlinea IN NUMBER,
      pcestado IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_set_cestado_lineaproceso';
      vparam         VARCHAR2(4000)
         := 'par¿metros - psproces : ' || psproces || ',pcestado : ' || pcestado
            || ',pnlinea : ' || pnlinea;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      UPDATE int_carga_ctrl_linea
         SET cestado = pcestado
       WHERE sproces = psproces
         AND nlinea = pnlinea;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, vobjectname, SQLERRM);
         RETURN 1000006;
   END f_set_cestado_lineaproceso;

--Fi Bug 16432-JBN-09/11/2010

   --Bug.: 0017155 - 18/01/2011 - ICV
     /*************************************************************************
         funci¿n que insert el fichero de carga una vez procesado y ok
         param in ccompani  : C¿digo Compa¿¿a
         param in tfichero :  Nombre del fichero
         param in ctipo   : Tipo de fichero
         param in fcarga   : Fecha de carga
         return             : 0 todo ha sido correcto
                              1 ha habido un error
     *************************************************************************/
   FUNCTION f_set_carga_fichero(
      pccompani IN NUMBER,
      ptfichero IN VARCHAR2,
      pctipo IN NUMBER,
      pfcarga IN DATE)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_set_carga_fichero';
      vparam         VARCHAR2(4000)
         := 'par¿metros - ccompani : ' || pccompani || ',tfichero : ' || ptfichero
            || ',ctipo : ' || pctipo || ' ,fcarga : ' || pfcarga;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      INSERT INTO carga_ficheros
                  (ccompani, tfichero, ctipo, fcarga)
           VALUES (pccompani, ptfichero, pctipo, pfcarga);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, vobjectname, SQLERRM);
         RETURN 1000006;
   END f_set_carga_fichero;

    /*************************************************************************
       funci¿n que devuelve un sys_refcursor con el ¿ltimo fichero cargado de la compa¿ia de la p¿liza/siniestro/recibo
       return             : 0 todo ha sido correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_get_carga_fichero(
      pctipo IN NUMBER,
      pccompani IN NUMBER,
      psseguro IN NUMBER,
      pnsinies IN VARCHAR2,
      pnrecibo IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos. f_get_carga_fichero';
      vparam         VARCHAR2(4000)
         := 'par¿metros - pctipo : ' || pctipo || ' pccompani : ' || pccompani
            || ',psseguro : ' || psseguro || ',pnsinies : ' || pnsinies || ',pnrecibo : '
            || pnrecibo || ',pcidioma : ' || pcidioma || ',psquery : ' || psquery;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vccompani      NUMBER;
      v_literal      NUMBER;
      v_whercomp     VARCHAR2(400);
   BEGIN
      IF pccompani IS NOT NULL THEN
         vccompani := pccompani;
      ELSIF psseguro IS NOT NULL THEN
         SELECT MAX(ccompani)
           INTO vccompani
           FROM seguros
          WHERE sseguro = psseguro;
      ELSIF pnsinies IS NOT NULL THEN
         SELECT MAX(s.ccompani)
           INTO vccompani
           FROM sin_siniestro ss, seguros s
          WHERE ss.sseguro = s.sseguro
            AND ss.nsinies = pnsinies;
      ELSIF pnrecibo IS NOT NULL THEN
         SELECT MAX(s.ccompani)
           INTO vccompani
           FROM recibos r, seguros s
          WHERE s.sseguro = r.sseguro
            AND r.nrecibo = pnrecibo;
      END IF;

      IF pctipo = 1 THEN   --P¿liza
         v_literal := 9901794;
      ELSIF pctipo = 2 THEN   -- Recibo
         v_literal := 9901795;
      ELSIF pctipo = 3 THEN   --Siniestro
         v_literal := 9901796;
      END IF;

      IF vccompani IS NULL THEN
         v_whercomp := ' is null';
      ELSE
         v_whercomp := ' = ' || vccompani;
      END IF;

      psquery :=
         'select replace(replace(f_axis_literales(' || v_literal || ',' || pcidioma
         || '),''#1#'',tcompani),''#2#'',to_char(cf.fcarga,''dd/mm/yyyy'')) || '' (''||  cf.TFICHERO|| '')''   linea
      from companias c, carga_ficheros cf
      where c.ccompani '
         || v_whercomp || ' and c.ccompani = cf.ccompani
      and cf.ctipo = ' || pctipo
         || ' and cf.fcarga = (select max(fcarga) from carga_ficheros cf2 where cf2.ctipo = cf.ctipo and cf.CCOMPANI = cf2.ccompani)';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, ' f_get_carga_fichero', SQLERRM);
         RETURN 1000006;
   END f_get_carga_fichero;

--Fi Bug 0017155

   /*************************************************************************
        funci¿n que devuelve el resumen de la carga
        param in psproces  : C¿digo del proceso
        param in pcidioma :  C¿digo del Idioma
        return             : Texto del resumen

        Bug 26050/142735 - 18/04/2013 - AMC
    *************************************************************************/
   FUNCTION f_get_resumen_carga(psproces IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'pac_gestion_procesos.f_get_resumen_carga';
      vparam         VARCHAR2(4000)
                         := 'par¿metros - psproces : ' || psproces || ' pcidioma:' || pcidioma;
      vnumerr        NUMBER(8) := 0;
      vresumen       VARCHAR2(1000);
   BEGIN
      SELECT f_axis_literales(9903844, pcidioma) || ': ' || SUM('1') || '. '
             || ff_desvalorfijo(800019, pcidioma, 1) || ':' || SUM(DECODE(cestado, 1, 1, 0))
             || ' ' || ff_desvalorfijo(800019, pcidioma, 2) || ':'
             || SUM(DECODE(cestado, 2, 1, 0)) || ' ' || ff_desvalorfijo(800019, pcidioma, 3)
             || ':' || SUM(DECODE(cestado, 3, 1, 0)) || ' '
             || ff_desvalorfijo(800019, pcidioma, 4) || ':' || SUM(DECODE(cestado, 4, 1, 0))
             || ' ' || ff_desvalorfijo(800019, pcidioma, 5) || ':'
             || SUM(DECODE(cestado, 5, 1, 0))
        INTO vresumen
        FROM int_carga_ctrl_linea ic
       WHERE sproces = psproces;

      RETURN vresumen;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, 1, vobjectname, SQLERRM);
         RETURN NULL;
   END f_get_resumen_carga;
END pac_gestion_procesos;
/

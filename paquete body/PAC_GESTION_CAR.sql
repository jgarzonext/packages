CREATE OR REPLACE PACKAGE BODY pac_gestion_car AS
   FUNCTION f_get_gca_parampre_conc(
      pncodparcon IN NUMBER,
      pcodseccion IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'pac_gestion_car.f_get_gca_parampre_conc';
      vparam         VARCHAR2(500) := '';
   BEGIN
      IF pcodseccion IS NOT NULL
         AND pcidioma IS NOT NULL THEN
         OPEN v_cursor FOR
            SELECT   ncodparcon, codseccion, cidioma, pregunta
                FROM gca_parampre_conc
               WHERE 1 = 1
                 AND codseccion = pcodseccion
                 AND cidioma = pcidioma
            ORDER BY ncodparcon;
      ELSE
         OPEN v_cursor FOR
            SELECT   ncodparcon, codseccion, cidioma, pregunta
                FROM gca_parampre_conc
            ORDER BY ncodparcon;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_parampre_conc;

   FUNCTION f_set_gca_parampre_conc(
      pncodparcon IN NUMBER,
      pcodseccion IN NUMBER,
      pcidioma IN NUMBER,
      ppregunta IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'pac_gestion_car.f_set_gca_parampre_conc';
      cont           NUMBER;
   BEGIN
      IF pncodparcon IS NULL
         AND pcodseccion IS NULL
         AND pcidioma IS NULL THEN
         INSERT INTO gca_parampre_conc
                     (ncodparcon, codseccion, cidioma, pregunta)
              VALUES (pncodparcon, pcodseccion, pcidioma, ppregunta);
      ELSE
         UPDATE gca_parampre_conc
            SET ncodparcon = pncodparcon,
                codseccion = pcodseccion,
                cidioma = pcidioma,
                pregunta = ppregunta
          WHERE 1 = 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_parampre_conc;

   FUNCTION f_del_gca_conciliacioncab(
      psidcon IN NUMBER,
      pacon IN NUMBER,
      pmcon IN NUMBER,
      pcsucursal IN NUMBER,
      pnnumideage IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      i              NUMBER := 1;
      verr           ob_error;
   BEGIN
      BEGIN
         IF psidcon IS NOT NULL THEN
            DELETE FROM gca_conciliacioncab
                  WHERE 1 = 1
                    AND sidcon = psidcon
                                        --AND acon = pacon
                                        --AND mcon = pmcon
                                        --AND csucursal = pcsucursal
                                        --AND nnumideage = pnnumideage
            ;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            verr := ob_error.instanciar(2292,
                                        f_axis_literales(2292,
                                                         pac_md_common.f_get_cxtidioma())
                                        || '  ' || SQLERRM);
            RETURN 2292;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         verr := ob_error.instanciar(2292,
                                     f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         RETURN 2292;
   END f_del_gca_conciliacioncab;

   FUNCTION f_get_gca_conciliacioncab(
      psidcon IN NUMBER,
      pacon IN NUMBER,
      pmcon IN NUMBER,
      pcsucursal IN NUMBER,
      pnnumideage IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'pac_gestion_car.f_get_gca_conciliacioncab';
      vparam         VARCHAR2(500) := '';
      misql          VARCHAR2(2500) := '';
   BEGIN
      -- (SELECT LTRIM(RTRIM(pd.tapelli1)) || LTRIM (RTRIM(pd.tapelli2)) || LTRIM(RTRIM(pd.tnombre)) FROM per_personas pp, per_detper pd
            --WHERE pp.sperson = pd.sperson AND pp.nnumide = nnumideage) nnumideage,
      misql :=
         ' SELECT sidcon, acon, mcon, tdesc, csucursal,  nnumideage,
        (select fichero.tdescrip from GCA_CARGACONC fichero where fichero.cfichero= cab.cfichero) tfichero, sproces, cestado,
                ncodacta, cusualt, falta, cusumod, fmodifi,
         ( SELECT pd.tapelli1 || Decode(pd.tapelli1, NULL, NULL,'' '') || pd.tapelli2 || Decode(pd.tapelli1  || pd.tapelli2,  NULL, NULL, Decode(tnombre, NULL, NULL, '' ''))
                       FROM per_detper pd,agentes a, per_personas p
                      WHERE pd.sperson = a.sperson
                        AND pd.sperson = p.sperson
                        AND p.nnumide = cab.nnumideage
                        AND ROWNUM = 1) tnomage
           FROM gca_conciliacioncab cab
          WHERE 1 = 1 ';

      IF psidcon IS NOT NULL THEN
         misql := misql || ' AND sidcon = ' || psidcon;
      ELSIF pacon IS NOT NULL THEN
         misql := misql || ' AND acon =  ' || pacon;
      ELSIF pmcon IS NOT NULL THEN
         misql := misql || ' AND mcon =  ' || pmcon;
      ELSIF pcsucursal IS NOT NULL THEN
         misql := misql || ' AND csucursal =  ' || pcsucursal;
      ELSIF pnnumideage IS NOT NULL THEN
         misql := misql || ' AND nnumideage =  ' || pnnumideage;
      END IF;

      p_control_error('' || f_sysdate, 'SQL: ', 'SQL: ' || misql);

      OPEN v_cursor FOR misql;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_conciliacioncab;

   FUNCTION f_set_gca_conciliacioncab(
      psidcon IN NUMBER,
      pacon IN NUMBER,
      pmcon IN NUMBER,
      ptdesc IN VARCHAR2,
      pcsucursal IN NUMBER,
      pnnumideage IN VARCHAR2,
      pcfichero IN NUMBER,
      psproces IN NUMBER,
      pcestado IN NUMBER,
      pncodacta IN NUMBER,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'pac_gestion_car.f_set_gca_conciliacioncab';
      cont           NUMBER;
   BEGIN
      IF psidcon IS NULL THEN
         INSERT INTO gca_conciliacioncab
                     (sidcon, acon, mcon, tdesc, csucursal,
                      nnumideage, cfichero, sproces, cestado, ncodacta, cusualt, falta,
                      cusumod, fmodifi)
              VALUES ((SELECT COUNT(sidcon) + 1
                         FROM gca_conciliacioncab), pacon, pmcon, ptdesc, pcsucursal,
                      pnnumideage, pcfichero, psproces, 1, pncodacta, pcusualt, pfalta,
                      pcusumod, pfmodifi);
      ELSIF psidcon IS NOT NULL THEN
         UPDATE gca_conciliacioncab
            SET acon = pacon,
                mcon = pmcon,
                tdesc = ptdesc,
                csucursal = pcsucursal,
                nnumideage = pnnumideage,
                cfichero = pcfichero,
                sproces = psproces,
                cestado = pcestado,
                ncodacta = pncodacta,
                cusualt = pcusualt,
                falta = pfalta,
                cusumod = pcusumod,
                fmodifi = pfmodifi
          WHERE 1 = 1
            AND sidcon = psidcon;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_control_error('CARTERA - ' || f_sysdate, vobject,
                         'MENSAJE: ' || SQLCODE || ' - ' || SQLERRM);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_conciliacioncab;

   FUNCTION f_del_gca_conciliaciondet(
      psidcon IN NUMBER,
      pnlinea IN NUMBER,
      pcagente IN NUMBER,
      pnnumidecli IN VARCHAR2,
      ptnomcli IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnrecibo IN NUMBER,
      pnmadurez IN NUMBER,
      pitotalr IN NUMBER,
      picomision IN NUMBER,
      pcmoneda IN VARCHAR2,
      pcoutsourcing IN NUMBER,
      ptnomcli_fic IN NUMBER,
      pnpoliza_fic IN NUMBER,
      pnrecibo_fic IN NUMBER,
      pnmadurez_fic IN NUMBER,
      pitotalr_fic IN NUMBER,
      picomision_fic IN NUMBER,
      pcmoneda_fic IN VARCHAR2,
      pcoutsourcing_fic IN NUMBER,
      pcrepetido IN NUMBER,
      pccruce IN NUMBER,
      pccrucedet IN NUMBER,
      pcestadoi IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      i              NUMBER := 1;
      verr           ob_error;
   BEGIN
      BEGIN
         IF psidcon IS NOT NULL THEN
            DELETE FROM gca_conciliaciondet
                  WHERE 1 = 1
                    AND sidcon = psidcon;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            verr := ob_error.instanciar(2292,
                                        f_axis_literales(2292,
                                                         pac_md_common.f_get_cxtidioma())
                                        || '  ' || SQLERRM);
            RETURN 2292;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         verr := ob_error.instanciar(2292,
                                     f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         RETURN 2292;
   END f_del_gca_conciliaciondet;

   FUNCTION f_get_gca_conciliaciondet(
      psidcon IN NUMBER,
      pnlinea IN NUMBER,
      pcagente IN NUMBER,
      pnnumidecli IN VARCHAR2,
      ptnomcli IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnrecibo IN NUMBER,
      pnmadurez IN NUMBER,
      pitotalr IN NUMBER,
      picomision IN NUMBER,
      pcmoneda IN VARCHAR2,
      pcoutsourcing IN NUMBER,
      ptnomcli_fic IN NUMBER,
      pnpoliza_fic IN NUMBER,
      pnrecibo_fic IN NUMBER,
      pnmadurez_fic IN NUMBER,
      pitotalr_fic IN NUMBER,
      picomision_fic IN NUMBER,
      pcmoneda_fic IN VARCHAR2,
      pcoutsourcing_fic IN NUMBER,
      pcrepetido IN NUMBER,
      pccruce IN NUMBER,
      pccrucedet IN NUMBER,
      pcestadoi IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_gestion_car.f_get_gca_conciliaciondet';
      vparam         VARCHAR2(500) := '';
      misql          VARCHAR2(4000) := '';
   BEGIN
      misql :=
         '  SELECT cgdet.sidcon, cgdet.nlinea, cgdet.cagente, cgdet.nnumidecli, cgdet.tnomcli, cgdet.npoliza, cgdet.ncertif, cgdet.nrecibo,
                   cgdet.nmadurez, cgdet.itotalr, cgdet.icomision, cgdet.cmoneda, decode(cgdet.coutsourcing,1,''NO'',2,''SI'',NULL) coutsourcing, cgdet.tnomcli_fic,
                   cgdet.npoliza_fic, cgdet.nrecibo_fic, cgdet.nmadurez_fic, cgdet.itotalr_fic, cgdet.icomision_fic,
                   cgdet.cmoneda_fic, cgdet.coutsourcing_fic, cgdet.crepetido, cgdet.ccruce, cgdet.ccrucedet, cgdet.cestadoi,
                   cgdet.cestado, cgdet.tobserva, cgdet.cusualt, cgdet.falta, cgdet.cusumod, cgdet.fmodifi,
                   ( SELECT pd.tapelli1 || Decode(pd.tapelli1, NULL, NULL,'' '') || pd.tapelli2 || Decode(pd.tapelli1  || pd.tapelli2,  NULL, NULL, Decode(tnombre, NULL, NULL, '' ''))
                       FROM per_detper pd,agentes a
                      WHERE pd.sperson = a.sperson
                        AND a.cagente = cgdet.cagente ) tnomage,
                   ( SELECT p.nnumide
                       FROM per_personas p, agentes a
                      WHERE p.sperson = a.sperson
                        AND a.cagente = cgdet.cagente) nnumideage,
                   ( SELECT pd.tapelli1 || Decode(pd.tapelli1, NULL, NULL,'' '') || pd.tapelli2 || Decode(pd.tapelli1  || pd.tapelli2,  NULL, NULL, Decode(tnombre, NULL, NULL, '' ''))
                       FROM per_detper pd,agentes a
                      WHERE pd.sperson = a.sperson
                        AND a.cagente = pac_agentes.F_get_cageliq(24, 2, cgdet.cagente) ) sucursal

              FROM gca_conciliaciondet cgdet
             WHERE 1 = 1 ';

      IF psidcon > 0 THEN
         misql := misql || ' AND sidcon = ' || psidcon;
      END IF;

      IF pnlinea IS NOT NULL THEN
         misql := misql || ' AND nlinea =  ' || pnlinea;
      END IF;

      IF pcagente > 0 THEN
         misql := misql || ' AND cagente =  ' || pcagente;
      END IF;

      IF pnnumidecli IS NOT NULL THEN
         misql := misql || ' AND nnumidecli =  ' || pnnumidecli;
      END IF;

      IF ptnomcli IS NOT NULL THEN
         misql := misql || ' AND tnomcli =  ' || ptnomcli;
      END IF;

      IF pnpoliza > 0 THEN
         misql := misql || ' AND npoliza =  ' || pnpoliza;
      END IF;

      IF pncertif > 0 THEN
         misql := misql || ' AND ncertif =  ' || pncertif;
      END IF;

      IF pnrecibo > 0 THEN
         misql := misql || ' AND nrecibo =  ' || pnrecibo;
      END IF;

      IF pnmadurez > 0 THEN
         misql := misql || ' AND nmadurez =  ' || pnmadurez;
      END IF;

      IF pitotalr > 0 THEN
         misql := misql || ' AND itotalr =  ' || pitotalr;
      END IF;

      IF picomision > 0 THEN
         misql := misql || ' AND icomision =  ' || picomision;
      END IF;

      IF pcmoneda IS NOT NULL THEN
         misql := misql || ' AND cmoneda =  ' || pcmoneda;
      END IF;

      IF pcoutsourcing > 0 THEN
         misql := misql || ' AND coutsourcing =  ' || pcoutsourcing;
      END IF;

      IF ptnomcli_fic > 0 THEN
         misql := misql || ' AND tnomcli_fic =  ' || ptnomcli_fic;
      END IF;

      IF pnpoliza_fic > 0 THEN
         misql := misql || ' AND npoliza_fic = pnpoliza_fic ' || ptnomcli_fic;
      END IF;

      IF pnrecibo_fic > 0 THEN
         misql := misql || ' AND nrecibo_fic =  ' || pnrecibo_fic;
      END IF;

      IF pnmadurez_fic > 0 THEN
         misql := misql || ' AND nmadurez_fic =  ' || pnmadurez_fic;
      END IF;

      IF pitotalr_fic > 0 THEN
         misql := misql || ' AND itotalr_fic =  ' || pitotalr_fic;
      END IF;

      IF picomision_fic > 0 THEN
         misql := misql || ' AND icomision_fic =  ' || picomision_fic;
      END IF;

      IF pcmoneda_fic IS NOT NULL THEN
         misql := misql || ' AND cmoneda_fic =  ' || pcmoneda_fic;
      END IF;

      IF pcoutsourcing_fic > 0 THEN
         misql := misql || ' AND coutsourcing_fic =  ' || pcoutsourcing_fic;
      END IF;

      IF pcrepetido > 0 THEN
         misql := misql || ' AND crepetido =  ' || pcrepetido;
      END IF;

      IF pccruce > 0 THEN
         misql := misql || ' AND ccruce =  ' || pccruce;
      END IF;

      IF pccrucedet > 0 THEN
         misql := misql || ' AND ccrucedet =  ' || pccrucedet;
      END IF;

      IF pcestadoi > 0 THEN
         misql := misql || ' AND cestadoi =  ' || pcestadoi;
      END IF;

      IF pcestado > 0 THEN
         misql := misql || ' AND cestado =  ' || pcestado;
      END IF;

      IF ptobserva IS NOT NULL THEN
         misql := misql || ' AND tobserva =  ' || ptobserva;
      END IF;

      IF pcusualt > 0 THEN
         misql := misql || ' AND cusualt =  ' || pcusualt;
      END IF;

      IF pfalta IS NOT NULL THEN
         misql := misql || ' AND falta =  ' || pfalta;
      END IF;

      IF pcusumod IS NOT NULL THEN
         misql := misql || ' AND cusumod =  ' || pcusumod;
      END IF;

      IF pfmodifi IS NOT NULL THEN
         misql := misql || ' AND fmodifi =  ' || pfmodifi;
      END IF;

      misql := misql || ' order by npoliza_fic, nrecibo_fic ,itotalr_fic  ';

      OPEN v_cursor FOR misql;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_conciliaciondet;

   FUNCTION f_set_gca_conciliaciondet(
      tipo IN NUMBER,
      psidcon IN NUMBER,
      pnlinea IN NUMBER,
      pcagente IN NUMBER,
      pnnumidecli IN VARCHAR2,
      ptnomcli IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnrecibo IN NUMBER,
      pnmadurez IN NUMBER,
      pitotalr IN NUMBER,
      picomision IN NUMBER,
      pcmoneda IN VARCHAR2,
      pcoutsourcing IN NUMBER,
      ptnomcli_fic IN NUMBER,
      pnpoliza_fic IN NUMBER,
      pnrecibo_fic IN NUMBER,
      pnmadurez_fic IN NUMBER,
      pitotalr_fic IN NUMBER,
      picomision_fic IN NUMBER,
      pcmoneda_fic IN VARCHAR2,
      pcoutsourcing_fic IN NUMBER,
      pcrepetido IN NUMBER,
      pccruce IN NUMBER,
      pccrucedet IN NUMBER,
      pcestadoi IN NUMBER,
      pcestado IN NUMBER,
      ptobserva IN VARCHAR2,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_gestion_car.f_set_gca_conciliaciondet';
      cont           NUMBER;
   BEGIN
      IF psidcon IS NOT NULL
         AND pnlinea IS NULL THEN
         INSERT INTO gca_conciliaciondet
                     (sidcon, nlinea, cagente, nnumidecli, tnomcli,
                      npoliza, ncertif, nrecibo, nmadurez, itotalr, icomision,
                      cmoneda, coutsourcing, tnomcli_fic, npoliza_fic, nrecibo_fic,
                      nmadurez_fic, itotalr_fic, icomision_fic, cmoneda_fic,
                      coutsourcing_fic, crepetido, ccruce, ccrucedet, cestadoi,
                      cestado, tobserva, cusualt, falta, cusumod, fmodifi)
              VALUES (psidcon, (SELECT COUNT(nlinea) + 1
                                  FROM gca_conciliaciondet), pcagente, pnnumidecli, ptnomcli,
                      pnpoliza, pncertif, pnrecibo, pnmadurez, pitotalr, picomision,
                      pcmoneda, pcoutsourcing, ptnomcli_fic, pnpoliza_fic, pnrecibo_fic,
                      pnmadurez_fic, pitotalr_fic, picomision_fic, pcmoneda_fic,
                      pcoutsourcing_fic, pcrepetido, pccruce, pccrucedet, pcestadoi,
                      pcestado, ptobserva, pcusualt, pfalta, pcusumod, pfmodifi);
      ELSE
         IF tipo = 1 THEN
            UPDATE gca_conciliaciondet
               SET ccruce = pccruce,
                   ccrucedet = pccrucedet,
                   cestado = pcestado,
                   tobserva = ptobserva
             WHERE sidcon = psidcon
               AND nlinea = pnlinea;
         ELSIF tipo = 2 THEN
            UPDATE gca_conciliaciondet
               SET sidcon = psidcon,
                   nlinea = pnlinea,
                   cagente = pcagente,
                   nnumidecli = pnnumidecli,
                   tnomcli = ptnomcli,
                   npoliza = pnpoliza,
                   ncertif = pncertif,
                   nrecibo = pnrecibo,
                   nmadurez = pnmadurez,
                   itotalr = pitotalr,
                   icomision = picomision,
                   cmoneda = pcmoneda,
                   coutsourcing = pcoutsourcing,
                   tnomcli_fic = ptnomcli_fic,
                   npoliza_fic = pnpoliza_fic,
                   nrecibo_fic = pnrecibo_fic,
                   nmadurez_fic = pnmadurez_fic,
                   itotalr_fic = pitotalr_fic,
                   icomision_fic = picomision_fic,
                   cmoneda_fic = pcmoneda_fic,
                   coutsourcing_fic = pcoutsourcing_fic,
                   crepetido = pcrepetido,
                   ccruce = pccruce,
                   ccrucedet = pccrucedet,
                   cestadoi = pcestadoi,
                   cestado = pcestado,
                   tobserva = ptobserva,
                   cusualt = pcusualt,
                   falta = pfalta,
                   cusumod = pcusumod,
                   fmodifi = pfmodifi
             WHERE 1 = 1
               AND sidcon = psidcon
               AND nlinea = pnlinea;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_conciliaciondet;

   FUNCTION f_del_gca_conciliacion_acta(
      pnconciact IN NUMBER,
      psidcon IN NUMBER,
      pcconacta IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      i              NUMBER := 1;
      verr           ob_error;
   BEGIN
      BEGIN
         IF pnconciact IS NOT NULL THEN
            DELETE FROM gca_conciliacion_acta
                  WHERE nconciact = pnconciact;
         ELSIF psidcon IS NOT NULL
               AND pcconacta IS NOT NULL THEN
            DELETE FROM gca_conciliacion_acta
                  WHERE sidcon = psidcon
                    AND cconacta = pcconacta;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            verr := ob_error.instanciar(2292,
                                        f_axis_literales(2292,
                                                         pac_md_common.f_get_cxtidioma())
                                        || '  ' || SQLERRM);
            RETURN 2292;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         verr := ob_error.instanciar(2292,
                                     f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         RETURN 2292;
   END f_del_gca_conciliacion_acta;

   FUNCTION f_get_gca_conciliacion_acta(
      pnconciact IN NUMBER,
      psidcon IN NUMBER,
      pcconacta IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_pac_gestion_car.f_get_gca_conciliacion_acta';
      vparam         VARCHAR2(500) := '';
   BEGIN
      IF pnconciact IS NOT NULL THEN
         OPEN v_cursor FOR
            SELECT nconciact, sidcon, cconacta, ncantidad, nvalor, crespage, crespcia,
                   fsolucion, tobs, cusualt, falta, cusumod, fmodifi,
                   (SELECT pregunta
                      FROM gca_parampre_conc
                     WHERE ncodparcon = cconacta) desconacta
              FROM gca_conciliacion_acta
             WHERE 1 = 1
               AND nconciact = pnconciact;
      END IF;

      IF psidcon IS NOT NULL THEN
         OPEN v_cursor FOR
            SELECT nconciact, sidcon, cconacta, ncantidad, nvalor, crespage, crespcia,
                   fsolucion, tobs, cusualt, falta, cusumod, fmodifi,
                   (SELECT pregunta
                      FROM gca_parampre_conc
                     WHERE ncodparcon = cconacta) desconacta
              FROM gca_conciliacion_acta
             WHERE sidcon = psidcon;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_conciliacion_acta;

   FUNCTION f_set_gca_conciliacion_acta(
      pnconciact IN NUMBER,
      psidcon IN NUMBER,
      pcconacta IN NUMBER,
      pncantidad IN NUMBER,
      pnvalor IN NUMBER,
      pcrespage IN NUMBER,
      pcrespcia IN NUMBER,
      pfsolucion IN DATE,
      ptobs IN VARCHAR2,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_pac_gestion_car.f_set_gca_conciliacion_acta';
      cont           NUMBER;
   BEGIN

      IF ptobs = '#FINALIZAR_ACTA#$' THEN
               UPDATE gca_conciliacioncab
                 SET cestado = 4
               WHERE sidcon = psidcon;

      ELSE

          IF pnconciact IS NULL
             AND psidcon IS NOT NULL
             AND pcconacta IS NOT NULL THEN
             INSERT INTO gca_conciliacion_acta
                         (nconciact, sidcon, cconacta, ncantidad, nvalor,
                          crespage, crespcia, fsolucion, tobs, cusualt, falta, cusumod,
                          fmodifi)
                  VALUES ((SELECT COUNT(nconciact) + 1
                             FROM gca_conciliacion_acta), psidcon, pcconacta, pncantidad, pnvalor,
                          pcrespage, pcrespcia, pfsolucion, ptobs, pcusualt, pfalta, pcusumod,
                          pfmodifi);
          ELSE
             UPDATE gca_conciliacion_acta
                SET sidcon = psidcon,
                    cconacta = pcconacta,
                    ncantidad = pncantidad,
                    nvalor = pnvalor,
                    crespage = pcrespage,
                    crespcia = pcrespcia,
                    fsolucion = pfsolucion,
                    tobs = ptobs,
                    cusualt = pcusualt,
                    falta = pfalta,
                    cusumod = pcusumod,
                    fmodifi = pfmodifi
              WHERE nconciact = pnconciact;

              UPDATE gca_conciliacioncab
                 SET cestado = 3
               WHERE sidcon = psidcon;
          END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_conciliacion_acta;

   FUNCTION f_get_gestion_cartera_recobro(
      pnnumide IN VARCHAR2, -- ML - EN CONSORCIOS EL NIT ES ALFANUMERICO
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN VARCHAR2,
      pnsinies IN NUMBER,
      pfinicio IN DATE,
      pffinal IN DATE,
      pcrecopen IN NUMBER,
      ptipo IN NUMBER,
      precurso IN NUMBER,
      popcion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'pac_gestion_car.f_get_gestion_cartera_recobro';
      vparam         VARCHAR2(500) := '';
      misql          VARCHAR2(4000) := '';
   BEGIN
	   -- INI - ML - 8/5/2019 - 3999 - cambio de filtro sint.csubtra = 50 por cunitra = 'RE00'
      misql :=
         'SELECT sint.nsinies nsinies_r, sint.ntramit ntramit_r, seg.npoliza npoliza_r,
       seg.ncertif ncertif_r,  pac_isqlfor.f_persona(null , 9, tom.sperson) ttomador_r,
       pac_isqlfor.f_persona(null , 9, ase.sperson) tasegurado_r,
       ( select pac_isqlfor.f_persona(null , 9, ben.sperson) from benespseg ben where ben.sseguro = seg.sseguro and nmovimi = (select max(nmovimi) from benespseg ben where ben.sseguro = seg.sseguro)) tbeneficiario_r,
       pac_isqlfor.f_persona(null , 9, agen.sperson) tagente_r
  FROM per_personas per, tomadores tom, seguros seg, asegurados ase, sin_siniestro sins,
       sin_tramita_movimiento sint, agentes agen
 WHERE tom.sseguro = seg.sseguro
   AND tom.sperson = per.sperson
   AND ase.sseguro = seg.sseguro
   AND agen.cagente = seg.cagente
   AND sins.sseguro = seg.sseguro
   AND sint.nsinies = sins.nsinies
   AND sint.cunitra = ''RE00'' ';
  -- FIN - ML - 8/5/2019 - 3999 - cambio de filtro sint.csubtra = 50 por cunitra = 'RE00'
  
	  -- INI - ML - 10/5/2019 - 3999 - se agrega filtro id/nit persona
      IF pnnumide > 0 THEN
         misql := misql || ' AND per.nnumide = ''' || pnnumide || '''';
      END IF;  
     -- FIN - ML - 10/5/2019 - 3999 - se agrega filtro id/nit persona

      IF pcramo > 0 THEN
         misql := misql || ' AND seg.cramo = ' || pcramo;
      END IF;

      IF psproduc > 0 THEN
         misql := misql || ' AND seg.sproduc =  ' || psproduc;
      END IF;

      IF pnpoliza > 0 THEN
         misql := misql || ' AND seg.npoliza =  ' || pnpoliza;
      END IF;

      IF pncertif IS NOT NULL THEN
         misql := misql || ' AND seg.ncertif =  ' || pncertif;
      END IF;

      IF pnsinies IS NOT NULL THEN
         misql := misql || ' AND sins.nsinies =  ' || pnsinies;
      END IF;

      IF pfinicio IS NOT NULL THEN
         --misql := misql || ' AND si.finicio =  ' || pfinicio;
         -- INI BUG - ML - 10/5/2019 - 3999 - la fecha debe estar entre comillas
         misql := misql || ' AND sins.falta >=  ''' || pfinicio || '''';
        -- FIN BUG - ML - 10/5/2019 - 3999 - la fecha debe estar entre comillas
      END IF;

      IF pffinal IS NOT NULL THEN
         --misql := misql || ' AND ffinal =  ' || pffinal;
         -- INI BUG - ML - 10/5/2019 - 3999 - la fecha debe estar entre comillas
         misql := misql || ' AND sins.falta <=  ''' || pffinal || '''';         
        -- FIN BUG - ML - 10/5/2019 - 3999 - la fecha debe estar entre comillas
      END IF;

      IF pcrecopen IS NOT NULL  AND pcrecopen = 1 THEN
         misql := misql || ' AND sint.nmovtra = (select max (stm.nmovtra) from sin_tramita_movimiento stm where stm.nsinies = sint.nsinies and stm.ntramit = sint.ntramit ) ';
      END IF;
      IF ptipo > 0 THEN
         misql := misql || ' AND sins.nsinies =  ' || ptipo;
      END IF;

      IF precurso IS NOT NULL THEN
         misql := misql || ' AND sint.ntramit =  ' || precurso;
      END IF;

      IF popcion IS NOT NULL THEN
         misql := misql || '';
      END IF;

      --p_control_error('SQL', 2, misql);
      OPEN v_cursor FOR misql;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gestion_cartera_recobro;

   FUNCTION f_get_depu_saldofavcli(
      ppercorte IN DATE,
      pcpendientes IN NUMBER,
      pcsucursal IN NUMBER,
      pnnumideage IN NUMBER,
      pnnumidecli IN NUMBER,
      pfdocini IN DATE,
      pfdocfin IN DATE,
      pndocsap IN NUMBER,
      pfcontini IN DATE,
      pfcontfin IN DATE,
      pntipo IN NUMBER,
      pnopcion IN NUMBER,
      pnmodo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_pac_gestion_car.f_get_depu_saldofavcli';
      vparam         VARCHAR2(500) := '';
      misql          VARCHAR2(4000) := '';
      verror         NUMBER;
   BEGIN
      IF pntipo = 1 THEN
         misql :=
            '
            SELECT   UNIQUE gcas.csucursal csucursal_n, PAC_REDCOMERCIAL.FF_DESAGENTE(gcas.csucursal,8,8) csucursal_t, gcas.nnumidecli nnumidecli_t, gcas.tnomcli tnomcli_t,
         (SELECT   SUM(deb.imovimi_moncia)
              FROM gca_salfavcli deb
             WHERE deb.imovimi_moncia > 0
               AND deb.csucursal = gcas.csucursal
               AND deb.nnumidecli = gcas.nnumidecli
          GROUP BY deb.csucursal, deb.nnumidecli, deb.tnomcli) idebito_t,
         (SELECT   SUM(cre.imovimi_moncia)
              FROM gca_salfavcli cre
             WHERE cre.imovimi_moncia < 0
               AND cre.csucursal = gcas.csucursal
               AND cre.nnumidecli = gcas.nnumidecli
          GROUP BY cre.csucursal, cre.nnumidecli, cre.tnomcli) icredito_t,
         (SELECT   SUM(cre.imovimi_moncia)
              FROM gca_salfavcli cre
             WHERE cre.csucursal = gcas.csucursal
               AND cre.nnumidecli = gcas.nnumidecli
          GROUP BY cre.csucursal, cre.nnumidecli, cre.tnomcli) isaldo_t
    FROM gca_salfavcli gcas
 WHERE 1= 1
   ';

         IF ppercorte IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontab <= ''' || ppercorte || '''' ;
         END IF;

         IF pcpendientes IS NOT NULL THEN
            misql := misql || '   AND  (SELECT SUM(cre.imovimi_moncia)
              FROM gca_salfavcli cre
             WHERE cre.csucursal = gcas.csucursal
               AND cre.nnumidecli = gcas.nnumidecli
          GROUP BY cre.csucursal, cre.nnumidecli, cre.tnomcli) <> 0 ';
         ELSE
             misql := misql || '   AND ( ((SELECT SUM(cre.imovimi_moncia)
              FROM gca_salfavcli cre
             WHERE cre.csucursal = gcas.csucursal
               AND cre.nnumidecli = gcas.nnumidecli
          GROUP BY cre.csucursal, cre.nnumidecli, cre.tnomcli) <> 0)
             OR (EXISTS( SELECT SUM(cre.imovimi_moncia)
              FROM gca_salfavcli cre
             WHERE cre.csucursal = gcas.csucursal
               AND cre.nnumidecli = gcas.nnumidecli
                having SUM(cre.imovimi_moncia) >0  
          GROUP BY cre.csucursal, cre.nnumidecli, cre.tnomcli,cre.sproces))) ';  
         END IF;

         IF pcsucursal > 0 THEN
            misql := misql || ' AND gcas.csucursal = ' || pcsucursal;
         END IF;

         IF pnnumideage > 0 THEN
            misql := misql || ' AND gcas.nnumideage = ' || pnnumideage;
         END IF;
         
         --INI SGM IAXIS-7653
         IF pnnumidecli > 0 THEN
            misql := misql || ' AND gcas.nnumidecli = ' || pnnumidecli;
         END IF;
         --FIN SGM IAXIS-7653

         IF pfdocini IS NOT NULL THEN
            misql := misql || ' AND gcas.fdoc >= '||chr(39)||pfdocini||chr(39);
         END IF;

         IF pfdocfin IS NOT NULL THEN
            misql := misql || ' AND gcas.fdoc <= '||chr(39)||pfdocfin||chr(39);
         END IF;

         IF pndocsap > 0 THEN
            misql := misql || ' AND gcas.ndocsap = ' || pndocsap;
         END IF;

         IF pfcontini IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontab >= '||chr(39)||pfcontini||chr(39);
         END IF;

         IF pfcontfin IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontab <= '||chr(39)||pfcontfin||chr(39);
         END IF;

         IF pntipo > 0 THEN
            --   misql := misql || ' AND ntipo = ' || pntipo;
            misql := misql || ' ';
         END IF;

         IF pnopcion > 0 THEN
            -- misql := misql || ' AND nopcion = ' || pnopcion;
            misql := misql || ' ';
         END IF;

         IF pnmodo > 0 THEN
            --   misql := misql || ' AND nmodo = ' || pnmodo;
            misql := misql || ' ';
         END IF;

         --p_control_error('SQL', 2, misql);
         misql := misql || ' ORDER BY PAC_REDCOMERCIAL.FF_DESAGENTE(gcas.csucursal,8,8), gcas.nnumidecli ';
      END IF;

      IF pntipo = 2 THEN
         --@BRSP ESTAS CONSULTAS SE REEMPLAZARAN POR LAS CORRECTAS
         misql :=
            'SELECT gcas.sgsfavcli,gcas.cgestion cgestion_d, PAC_REDCOMERCIAL.FF_DESAGENTE(gcas.csucursal,8,8) csucursal_d, gcas.fdoc fdoc_d, gcas.ndocsap ndocsap_d,
                   gcas.nnumideage nnumideage_d, gcas.tnomage tnomage_d, gcas.nnumidecli nnumidecli_d,
                   gcas.tnomcli tnomcli_d, gcas.fcontab fcontab_d,
                   (CASE
                       WHEN gcas.imovimi_moncia > 0 THEN gcas.imovimi_moncia
                    END) idebito_d,(CASE
                                       WHEN gcas.imovimi_moncia < 0 THEN gcas.imovimi_moncia
                                    END) icredito_d, gcas.imovimi_moncia isaldo_d, tinconsistencia tinconsistencia_d
              FROM gca_salfavcli gcas
          where 1=1 ';

         IF ppercorte IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontab <= ''' || ppercorte || '''' ;
         END IF;

         IF pcpendientes > 0 THEN
            -- misql := misql || ' AND cpendientes = ' || pcpendientes;
            misql := misql || ' ';
         END IF;

         IF pcsucursal > 0 THEN
            misql := misql || ' AND gcas.csucursal = ' || pcsucursal;
         END IF;

         IF pnnumideage > 0 THEN
            misql := misql || ' AND gcas.nnumideage = ' || pnnumideage;
         END IF;

         IF pfdocini IS NOT NULL THEN
            misql := misql || ' AND gcas.fdoc >= '||chr(39)||pfdocini||chr(39);
         END IF;

         IF pfdocfin IS NOT NULL THEN
            misql := misql || ' AND gcas.fdoc <= '||chr(39)||pfdocfin||chr(39);
         END IF;

         IF pndocsap > 0 THEN
            misql := misql || ' AND gcas.ndocsap = ' || pndocsap;
         END IF;

         IF pfcontini IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontab >= '||chr(39)||pfcontini||chr(39);
         END IF;

         IF pfcontfin IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontab <= '||chr(39)||pfcontfin||chr(39);
         END IF;

         IF pntipo > 0 THEN
            --   misql := misql || ' AND ntipo = ' || pntipo;
            misql := misql || ' ';
         END IF;

         IF pnopcion > 0 THEN
            misql := misql || ' AND gcas.csucursal = ' || pnopcion;
            misql := misql || ' ';
         END IF;

         IF pnmodo > 0 THEN
            misql := misql || ' AND gcas.nnumidecli = ' || pnmodo;
            misql := misql || ' ';
         END IF;

         --p_control_error('SQL', 2, misql);
         misql := misql || ' ORDER BY PAC_REDCOMERCIAL.FF_DESAGENTE(gcas.csucursal,8,8), gcas.nnumidecli';
      --p_control_error('SQL', 2, misql);
      END IF;

      p_control_error('' || f_sysdate, ' - ', 'SQL: ' || misql);

      -------005
      IF pntipo = 3 THEN
         misql :=
            '
            SELECT   UNIQUE gcas.csucursal csucursal_n, PAC_REDCOMERCIAL.FF_DESAGENTE(gcas.csucursal,8,8) csucursal_t, gcas.nnumidecli nnumidecli_t, gcas.tnomcli tnomcli_t,
         (SELECT   SUM(deb.imovimi_moncia)
              FROM gca_salfavcli deb
             WHERE deb.imovimi_moncia > 0
               AND deb.csucursal = gcas.csucursal
               AND deb.nnumidecli = gcas.nnumidecli
          GROUP BY deb.csucursal, deb.nnumidecli, deb.tnomcli) idebito_t,
         (SELECT   SUM(cre.imovimi_moncia)
              FROM gca_salfavcli cre
             WHERE cre.imovimi_moncia < 0
               AND cre.csucursal = gcas.csucursal
               AND cre.nnumidecli = gcas.nnumidecli
          GROUP BY cre.csucursal, cre.nnumidecli, cre.tnomcli) icredito_t,
         (SELECT   SUM(cre.imovimi_moncia)
              FROM gca_salfavcli cre
             WHERE cre.csucursal = gcas.csucursal
               AND cre.nnumidecli = gcas.nnumidecli
          GROUP BY cre.csucursal, cre.nnumidecli, cre.tnomcli) isaldo_t
    FROM gca_salfavcli gcas
 WHERE 1= 1
  AND CGESTION = 1 ';

         IF ppercorte IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontab <= ''' || ppercorte || '''' ;
         END IF;

         IF pcpendientes IS NOT NULL THEN
            misql := misql || '   AND (SELECT   SUM(cre.imovimi_moncia)
              FROM gca_salfavcli cre
             WHERE cre.csucursal = gcas.csucursal
               AND cre.nnumidecli = gcas.nnumidecli
          GROUP BY cre.csucursal, cre.nnumidecli, cre.tnomcli) <> 0 ';
         END IF; 

         IF pcsucursal > 0 THEN
            misql := misql || ' AND gcas.csucursal = ' || pcsucursal;
         END IF;

         IF pnnumideage > 0 THEN
            misql := misql || ' AND gcas.nnumideage = ' || pnnumideage;
         END IF;
         
         --INI SGM IAXIS-7653
         IF pnnumidecli > 0 THEN
            misql := misql || ' AND gcas.nnumidecli = ' || pnnumidecli;
         END IF;
         --FIN SGM IAXIS-7653         

         IF pfdocini IS NOT NULL THEN
            misql := misql || ' AND gcas.fdoc >= '||chr(39)||pfdocini||chr(39);
         END IF;

         IF pfdocfin IS NOT NULL THEN
            misql := misql || ' AND gcas.fdoc <= '||chr(39)||pfdocfin||chr(39);
         END IF;

         IF pndocsap > 0 THEN
            misql := misql || ' AND gcas.ndocsap = ' || pndocsap;
         END IF;

         IF pfcontini IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontab >= '||chr(39)||pfcontini||chr(39);
         END IF;

         IF pfcontfin IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontab <= '||chr(39)||pfcontfin||chr(39);
         END IF;

         IF pntipo > 0 THEN
            --   misql := misql || ' AND ntipo = ' || pntipo;
            misql := misql || ' ';
         END IF;

         IF pnopcion > 0 THEN
            -- misql := misql || ' AND nopcion = ' || pnopcion;
            misql := misql || ' ';
         END IF;

         IF pnmodo > 0 THEN
            --   misql := misql || ' AND nmodo = ' || pnmodo;
            misql := misql || ' ';
         END IF;

         --p_control_error('SQL', 2, misql);
         misql := misql || ' ORDER BY PAC_REDCOMERCIAL.FF_DESAGENTE(gcas.csucursal,8,8), gcas.nnumidecli ';
      END IF;

      IF pntipo = 4 THEN
        misql :=
            'SELECT gcas.sgsfavcli,gcas.cgestion cgestion_d, PAC_REDCOMERCIAL.FF_DESAGENTE(gcas.csucursal,8,8) csucursal_d, gcas.fdoc fdoc_d, gcas.ndocsap ndocsap_d,
                   gcas.nnumideage nnumideage_d, gcas.tnomage tnomage_d, gcas.nnumidecli nnumidecli_d,
                   gcas.tnomcli tnomcli_d, gcas.fcontab fcontab_d,
                   (CASE
                       WHEN gcas.imovimi_moncia > 0 THEN gcas.imovimi_moncia
                    END) idebito_d,(CASE
                                       WHEN gcas.imovimi_moncia < 0 THEN gcas.imovimi_moncia
                                    END) icredito_d, gcas.imovimi_moncia isaldo_d, tinconsistencia tinconsistencia_d
              FROM gca_salfavcli gcas
          where 1=1 ';

         IF ppercorte IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontab <= ''' || ppercorte || '''' ;
         END IF;

         IF pcpendientes > 0 THEN
            -- misql := misql || ' AND cpendientes = ' || pcpendientes;
            misql := misql || ' ';
         END IF;

         IF pcsucursal > 0 THEN
            misql := misql || ' AND gcas.csucursal = ' || pcsucursal;
         END IF;

         IF pnnumideage > 0 THEN
            misql := misql || ' AND gcas.nnumideage = ' || pnnumideage;
         END IF;

         IF pfdocini IS NOT NULL THEN
            misql := misql || ' AND gcas.fdocini >= ' || pfdocini;
         END IF;

         IF pfdocfin IS NOT NULL THEN
            misql := misql || ' AND gcas.fdocfin <= ' || pfdocfin;
         END IF;

         IF pndocsap > 0 THEN
            misql := misql || ' AND gcas.ndocsap = ' || pndocsap;
         END IF;

         IF pfcontini IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontini >= ' || pfcontini;
         END IF;

         IF pfcontfin IS NOT NULL THEN
            misql := misql || ' AND gcas.fcontfin <= ' || pfcontfin;
         END IF;

         IF pntipo > 0 THEN
            --   misql := misql || ' AND ntipo = ' || pntipo;
            misql := misql || ' ';
         END IF;

         IF pnopcion > 0 THEN
            misql := misql || ' AND gcas.csucursal = ' || pnopcion;
            misql := misql || ' ';
         END IF;

         IF pnmodo > 0 THEN
            misql := misql || ' AND gcas.nnumidecli = ' || pnmodo;
            misql := misql || ' ';
         END IF;

         --p_control_error('SQL', 2, misql);
         misql := misql || ' ORDER BY PAC_REDCOMERCIAL.FF_DESAGENTE(gcas.csucursal,8,8), gcas.nnumidecli';
      --p_control_error('SQL', 2, misql);
      END IF;
 verror := pac_log.f_log_consultas(misql, 'f_get_depu_saldofavcli', 1); 
      OPEN v_cursor FOR misql;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_depu_saldofavcli;

   FUNCTION f_del_sin_apuntes_rec(
      pidobs_gr IN NUMBER,
      pnsinies_r IN NUMBER,
      pntramit_r IN NUMBER,
      pnpoliza_r IN NUMBER,
      pttitobs IN VARCHAR2,
      pfalta_gr IN DATE,
      pcusualt_gr IN VARCHAR2,
      ptobs IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      i              NUMBER := 1;
      verr           ob_error;
   BEGIN
      BEGIN
         IF pidobs_gr IS NOT NULL THEN
            DELETE FROM sin_apuntes_rec
                  WHERE 1 = 1
                    AND idobs_gr = pidobs_gr;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            verr := ob_error.instanciar(2292,
                                        f_axis_literales(2292,
                                                         pac_md_common.f_get_cxtidioma())
                                        || '  ' || SQLERRM);
            RETURN 2292;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         verr := ob_error.instanciar(2292,
                                     f_axis_literales(2292, pac_md_common.f_get_cxtidioma())
                                     || '  ' || SQLERRM);
         RETURN 2292;
   END f_del_sin_apuntes_rec;

   FUNCTION f_get_sin_apuntes_rec(
      pidobs_gr IN NUMBER,
      pnsinies_r IN NUMBER,
      pntramit_r IN NUMBER,
      pnpoliza_r IN NUMBER,
      pttitobs IN VARCHAR2,
      pfalta_gr IN DATE,
      pcusualt_gr IN VARCHAR2,
      ptobs IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_pac_gestion_car.f_get_sin_apuntes_rec';
      vparam         VARCHAR2(500) := '';
   BEGIN
      IF pidobs_gr IS NULL
         AND pnsinies_r IS NOT NULL
         AND pntramit_r IS NOT NULL
         AND pnpoliza_r IS NOT NULL THEN
         OPEN v_cursor FOR
            SELECT idobs_gr, nsinies_r, ntramit_r, npoliza_r, ttitobs, falta_gr, cusualt_gr,
                   tobs
              FROM sin_apuntes_rec
             WHERE 1 = 1
               AND nsinies_r = pnsinies_r
               AND ntramit_r = pntramit_r
               AND npoliza_r = pnpoliza_r;
      END IF;

      IF pidobs_gr IS NOT NULL THEN
         OPEN v_cursor FOR
            SELECT idobs_gr, nsinies_r, ntramit_r, npoliza_r, ttitobs, falta_gr, cusualt_gr,
                   tobs
              FROM sin_apuntes_rec
             WHERE idobs_gr = pidobs_gr;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_sin_apuntes_rec;

   FUNCTION f_set_sin_apuntes_rec(
      pidobs_gr IN NUMBER,
      pnsinies_r IN NUMBER,
      pntramit_r IN NUMBER,
      pnpoliza_r IN NUMBER,
      pttitobs IN VARCHAR2,
      pfalta_gr IN DATE,
      pcusualt_gr IN VARCHAR2,
      ptobs IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_pac_gestion_car.f_set_sin_apuntes_rec';
      cont           NUMBER;
     -- INI - AXIS 3999 - 13/05/2019 - Empresa, code
      cod_empresa    NUMBER := pac_md_common.f_get_cxtempresa;
      idobs			 NUMBER;
     -- FIN - AXIS 3999 - 13/05/2019 - Empresa, code
   BEGIN
      IF pidobs_gr IS NULL
         AND pnsinies_r IS NOT NULL
         AND pntramit_r IS NOT NULL
         AND pnpoliza_r IS NOT NULL THEN
         INSERT INTO sin_apuntes_rec
                     (idobs_gr, nsinies_r, ntramit_r, npoliza_r,
                      ttitobs, falta_gr, cusualt_gr, tobs)
              VALUES ((SELECT COUNT(idobs_gr) + 1
                         FROM sin_apuntes_rec), pnsinies_r, pntramit_r, pnpoliza_r,
                      pttitobs, f_sysdate, pcusualt_gr, ptobs);
         -- INI - AXIS 3999 - 13/05/2019 - Insert en tablas agd_observaciones y agd_movobs                  
         SELECT NVL(MAX(idobs) + 1, 1)
              INTO idobs
              FROM agd_observaciones;
         INSERT INTO agd_observaciones
			(CEMPRES, IDOBS, CCONOBS, CTIPOBS, TTITOBS, TOBS, FOBS, FRECORDATORIO, CTIPAGD, SSEGURO, NRECIBO, CAGENTE, NSINIES, NTRAMIT, CAMBITO, CPRIORI, CPRIVOBS, PUBLICO, CUSUALT, FALTA, CUSUMOD, FMODIFI, SPERSON, SGSFAVCLI, IDDOCGEDOX, TFILENAME, DESCRIPCION)
			VALUES(cod_empresa, idobs, 4, 1, pttitobs, ptobs, NULL, NULL, 4, NULL, NULL, NULL, pnsinies_r, 0, NULL, NULL, NULL, 1, pcusualt_gr, f_sysdate, pcusualt_gr, NULL, NULL, NULL, NULL, NULL, NULL);
		INSERT INTO agd_movobs
		(CEMPRES, IDOBS, NMOVOBS, CESTOBS, FESTOBS, CUSUALT, FALTA)
		VALUES(cod_empresa, idobs, 1, 0, f_sysdate, pcusualt_gr, NULL);		         
         -- FIN - AXIS 3999 - 13/05/2019 - Insert en tablas agd_observaciones y agd_movobs
      ELSE
         UPDATE sin_apuntes_rec
            SET nsinies_r = pnsinies_r,
                ntramit_r = pntramit_r,
                npoliza_r = pnpoliza_r,
                ttitobs = pttitobs,
                falta_gr = pfalta_gr,
                cusualt_gr = pcusualt_gr,
                tobs = ptobs
          WHERE idobs_gr = pidobs_gr;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_sin_apuntes_rec;

   FUNCTION f_get_agd_observaciones(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pcagente IN NUMBER,
      pnsinies IN NUMBER,
      pntramit IN VARCHAR2,
      ptipo IN DATE,
      pparama IN VARCHAR2,
      pparamb IN VARCHAR2,
      psgsfavcli IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_gestion_car.f_get_agd_observaciones';
      vparam         VARCHAR2(500) := '';
   BEGIN
      IF pnsinies > 0 THEN
         OPEN v_cursor FOR
            SELECT *
              FROM agd_observaciones
             WHERE 1 = 1
               AND nsinies = pnsinies;
      END IF;

      IF pparama = 1 THEN
         OPEN v_cursor FOR
            SELECT *
              FROM agd_observaciones
             WHERE 1 = 1
               AND sgsfavcli = psgsfavcli;
      END IF;

      IF pparama = 2 THEN
         OPEN v_cursor FOR
            SELECT *
              FROM agd_observaciones
             WHERE 1 = 1
               AND idobs = pparamb
               AND sgsfavcli = psgsfavcli;
      END IF;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_agd_observaciones;

   FUNCTION f_get_gca_cargaconc(
      pcempres IN NUMBER,
      pcfichero IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'PAC_rea.f_get_gca_cargaconc';
      vparam         VARCHAR2(500) := '';
   BEGIN
      OPEN v_cursor FOR
         SELECT   cempres, cfichero, tdescrip, nfiladatos, ttablatemp, tsepara, tvalnom,
                  nnumideage, cusualt, falta, cusumod, fmodifi
             FROM gca_cargaconc
         ORDER BY tdescrip;

      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_cargaconc;

   FUNCTION f_set_gca_salfavcli(
      psgsfavcli IN NUMBER,
      pnnumidecli IN VARCHAR2,
      ptnomcli IN VARCHAR2,
      pndocsap IN NUMBER,
      pfdoc IN DATE,
      pfcontab IN DATE,
      pcsucursal IN NUMBER,
      pnnumideage IN VARCHAR2,
      ptnomage IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN VARCHAR2,
      pnrecibo IN NUMBER,
      pimovimi_moncia IN NUMBER,
      psproces IN NUMBER,
      pcestado IN NUMBER,
      pcgestion IN NUMBER,
      ptinconsistencia IN VARCHAR2,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_rea.f_set_gca_salfavcli';
      cont           NUMBER;
   BEGIN
      IF psgsfavcli IS NULL THEN
         INSERT INTO gca_salfavcli
                     (sgsfavcli, nnumidecli, tnomcli, ndocsap, fdoc, fcontab,
                      csucursal, nnumideage, tnomage, npoliza, ncertif, nrecibo,
                      imovimi_moncia, sproces, cestado, cgestion, tinconsistencia,
                      cusualt, falta, cusumod, fmodifi)
              VALUES (psgsfavcli, pnnumidecli, ptnomcli, pndocsap, pfdoc, pfcontab,
                      pcsucursal, pnnumideage, ptnomage, pnpoliza, pncertif, pnrecibo,
                      pimovimi_moncia, psproces, pcestado, pcgestion, ptinconsistencia,
                      pcusualt, pfalta, pcusumod, pfmodifi);
      ELSE
         UPDATE gca_salfavcli
            SET   /*nnumidecli = pnnumidecli,
                  tnomcli = ptnomcli,
                  ndocsap = pndocsap,
                  fdoc = pfdoc,
                  fcontab = pfcontab,
                  csucursal = pcsucursal,
                  nnumideage = pnnumideage,
                  tnomage = ptnomage,
                  npoliza = pnpoliza,
                  ncertif = pncertif,
                  nrecibo = pnrecibo,
                  imovimi_moncia = pimovimi_moncia,
                  sproces = psproces,
                  cestado = pcestado,*/
               cgestion = pcgestion
          /*,tinconsistencia = ptinconsistencia,
          cusualt = pcusualt,
          falta = pfalta,
          cusumod = pcusumod,
          fmodifi = pfmodifi*/
         WHERE  sgsfavcli = psgsfavcli;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_salfavcli;

   FUNCTION f_set_agd_observaciones(
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pcconobs IN NUMBER,
      pctipobs IN NUMBER,
      pttitobs IN VARCHAR2,
      ptobs IN VARCHAR2,
      pfobs IN DATE,
      pfrecordatorio IN DATE,
      pctipagd IN NUMBER,
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pcagente IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcprivobs IN NUMBER,
      ppublico IN NUMBER,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      pcusumod IN VARCHAR2,
      pfmodifi IN DATE,
      psgsfavcli IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'PAC_gestion_car.f_set_agd_observaciones';
      cont           NUMBER;
      idgen          NUMBER := 0;
   BEGIN
      IF pidobs IS NULL THEN
         SELECT MAX(idobs) + 1
           INTO idgen
           FROM agd_observaciones;

         INSERT INTO agd_observaciones
                     (cempres, idobs, cconobs, ctipobs, ttitobs, tobs, fobs, frecordatorio,
                      ctipagd, sseguro, nrecibo, cagente, nsinies, ntramit, cambito,
                      cpriori, cprivobs, publico, cusualt, falta, cusumod, fmodifi,
                      sgsfavcli)
              VALUES (pcempres, idgen, pcconobs, 1, pttitobs, ptobs, pfobs, pfrecordatorio,
                      pctipagd, psseguro, pnrecibo, pcagente, pnsinies, pntramit, pcambito,
                      pcpriori, pcprivobs, ppublico, pcusualt, pfalta, pcusumod, pfmodifi,
                      psgsfavcli);
      ELSE
         SELECT idobs
           INTO idgen
           FROM agd_observaciones
          WHERE idobs = pidobs;

         UPDATE agd_observaciones
            SET ctipagd = pctipagd,
                ttitobs = pttitobs,
                tobs = ptobs,
                cconobs = pcconobs,
                falta = pfalta
          WHERE 1 = 1
            AND idobs = pidobs;
      END IF;

      RETURN idgen;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_agd_observaciones;

   FUNCTION f_get_gca_docgsfavcli(pidobs IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      v_cursor       sys_refcursor;
      --
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'pac_md_contragarantias.f_get_gca_docgsfavcli';
      vparam         VARCHAR2(500) := 'pidobs: ' || pidobs;
   --
   BEGIN
      --
      OPEN v_cursor FOR
         SELECT pac_axisgedox.f_get_descdoc(iddocgedox) TDESCRIP,
                SUBSTR(pac_axisgedox.f_get_filedoc(iddocgedox),
                       INSTR(pac_axisgedox.f_get_filedoc(iddocgedox), '\', -1) + 1,
                       LENGTH(pac_axisgedox.f_get_filedoc(iddocgedox))) FICHERO,
                tobserv, falta FARCHIV, fcaduci FELIMIN
           FROM gca_docgsfavcli
          WHERE idobs = pidobs;

      --
      RETURN v_cursor;
   --
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
   END f_get_gca_docgsfavcli;

   FUNCTION f_ins_gca_docgsfavcli(
      pidobs IN NUMBER,
      piddocgdx IN NUMBER,
      pctipo IN NUMBER,
      ptobserv IN VARCHAR2,
      ptfilename IN VARCHAR2,
      pfcaduci IN DATE,
      pfalta IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vpasexec       NUMBER := 1;
      vobject        VARCHAR2(200) := 'PAC_MD_CONTRAGARANTIAS.f_ins_gca_docgsfavcli';
      vparam         VARCHAR2(500)
         := 'pidobs: ' || pidobs || ' piddocgdx: ' || piddocgdx || ' pctipo: ' || pctipo
            || ' ptobserv: ' || ptobserv || ' pfcaduci: ' || pfcaduci || ' pfalta: ' || pfalta;
      --
      vnum_err       NUMBER;
      vterror        VARCHAR2(200);
      viddoc         NUMBER(8) := 0;
   --
   BEGIN
      --
      IF pidobs IS NULL
         OR pctipo IS NULL THEN
         --
         RAISE e_param_error;
      --
      END IF;

      --
      IF piddocgdx IS NULL THEN
         --
         vpasexec := 2;
         pac_axisgedox.grabacabecera(f_user, ptfilename, ptobserv, 1, 1, pctipo, vterror,
                                     viddoc);

         --
         IF vterror IS NOT NULL
            OR NVL(viddoc, 0) = 0 THEN
            vpasexec := 3;
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, vterror);
            RAISE e_object_error;
         END IF;

         --
         pac_axisgedox.actualiza_gedoxdb(ptfilename, viddoc, vterror);
      --
      END IF;

      --
      vpasexec := 4;

      INSERT INTO gca_docgsfavcli
                  (sgsfavcli, idobs, iddocgedox, cusualt, falta, cusumod,
                   fmodifi, fcaduci)
           VALUES ((SELECT COUNT(sgsfavcli) + 1
                      FROM gca_docgsfavcli), pidobs, piddocgdx, f_user, f_sysdate, NULL,
                   NULL, NULL);

      COMMIT;
      --
      RETURN vnum_err;
   --
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
   END f_ins_gca_docgsfavcli;

   FUNCTION f_get_gca_docgsfavclis(pidobs IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      v_cursor       sys_refcursor;
      --
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      vpasexec       NUMBER;
      vobject        VARCHAR2(200) := 'pac_md_rea.f_get_gca_docgsfavclis';
      vparam         VARCHAR2(500) := 'pidobs: ' || pidobs;
   --
   BEGIN
      --
      OPEN v_cursor FOR
         SELECT SUBSTR(pac_axisgedox.f_get_filedoc(iddocgedox),
                       INSTR(pac_axisgedox.f_get_filedoc(iddocgedox), '\', -1) + 1,
                       LENGTH(pac_axisgedox.f_get_filedoc(iddocgedox))) nombre,
                SUBSTR(pac_axisgedox.f_get_filedoc(iddocgedox),
                       INSTR(pac_axisgedox.f_get_filedoc(iddocgedox), '\', -1) + 1,
                       LENGTH(pac_axisgedox.f_get_filedoc(iddocgedox))) fichero,
                iddocgedox AS iddoc, tobserv tdescrip, falta, fcaduci
           FROM gca_docgsfavcli
          WHERE idobs = pidobs;

      --
      RETURN v_cursor;
   --
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
   END f_get_gca_docgsfavclis;
   FUNCTION f_get_gca_mapeo(
      pcfichero IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      v_cursor       sys_refcursor;
      vquery         VARCHAR2(1000) := '';
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'pac_md_gestion_car.f_get_gca_mapeo';
   BEGIN
      vquery := 'SELECT (SELECT TDESCRIP FROM GCA_CARGACONC WHERE CFICHERO = A.CFICHERO) TFICHERO, REPLACE(A.TCOLORI, chr(39), ''$[]'') TCOLORI , A.TCOLORI TCOLORI_A, A.TCOLDEST, NVL(( select unique comments from ALL_COL_COMMENTS where  table_name = ''GCA_CONCILIACIONDET'' and column_name = A.TCOLDEST),( select unique comments from ALL_COL_COMMENTS where  table_name = ''GCA_SALFAVCLI'' and column_name = A.TCOLDEST) ) TDESCOLM, CFICHERO FROM gca_cargaconc_mapeo A ';
      IF pcfichero is not null then
       vquery := vquery || ' WHERE A.cfichero = '||pcfichero;
      END IF;

      vquery := vquery || ' ORDER BY CFICHERO ';

      OPEN v_cursor FOR vquery;
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_gca_mapeo;

   FUNCTION f_set_gca_mapeo(
      pcfichero IN NUMBER,
      ptcolir IN VARCHAR2,
      ptcoldest IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := '';
      vobject        VARCHAR2(200) := 'pac_md_gestion_car.f_set_gca_mapeo';
      cont           NUMBER;
   BEGIN
      UPDATE gca_cargaconc_mapeo
         SET tcolori = ptcolir
       WHERE pcfichero = pcfichero
         AND tcoldest = ptcoldest;

         COMMIT;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_gca_mapeo;
END pac_gestion_car;
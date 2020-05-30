create or replace PACKAGE pac_alctr126 IS
   /***********************************************************************************************
    Package per traspassar les taules seguros a estseguros i de estseguros a seguros.
    --modificaci: 05-01-2007 XCG s'afegeixen les taules SEGUROS_AHO i ESTSEGUROS_AHO
    --modificaci: 16-07-2007 RSC s'afegeixen les taules SEGUROS_ULK, ESTSEGUROS_ULK, SEGDISIN2 y ESTSEGDISIN2.
    --modificaci: 01-10-2007 JRH Tarea 2674 Intereses LRC. S'afegeixen els camps ndesde i nhasta de __intertecseg
    --modificaci: 29-05-2008 XVM Bug 6008: se aaden las funciones para guardar los histricos Tomadores, Asegurados, Riesgos
   ************************************************************************************************/
   PROCEDURE borrar_tablas_est(psseguro IN NUMBER);

   PROCEDURE traspaso_tablas_est(psseguro IN NUMBER,
                                 pfefecto IN DATE,
                                 pcdomper IN NUMBER,
                                 mens     OUT VARCHAR2,
                                 programa IN VARCHAR2 DEFAULT 'ALCTR126',
                                 p_agecob NUMBER DEFAULT NULL,
                                 pnmovimi IN NUMBER DEFAULT NULL,
                                 pffinefe IN DATE DEFAULT NULL,
                                 pmovsegu IN NUMBER DEFAULT NULL);

   -- BUG 0022839 - FAL - 24/07/2012
   PROCEDURE traspaso_seguroscol(psseguro IN NUMBER,
                                 pnmovimi IN NUMBER,
                                 pssegpol IN NUMBER,
                                 mens     OUT VARCHAR2);

   -- FI BUG 0022839
   PROCEDURE traspaso_riesgos(psseguro IN NUMBER,
                              pssegpol IN NUMBER,
                              programa IN VARCHAR2 DEFAULT 'ALCTR126',
                              mens     OUT VARCHAR2,
                              pnmovimi IN NUMBER DEFAULT NULL);

   PROCEDURE traspaso_garantias(psseguro IN NUMBER,
                                pssegpol IN NUMBER,
                                pspertom IN NUMBER,
                                programa IN VARCHAR2 DEFAULT 'ALCTR126',
                                mens     OUT VARCHAR2,
                                pnmovimi IN NUMBER DEFAULT NULL,
                                pfefecto IN DATE DEFAULT NULL);

   PROCEDURE traspaso_movseguro(psseguro IN NUMBER,
                                pfefecto IN DATE,
                                pcdomper IN NUMBER,
                                mens     OUT VARCHAR2);

   PROCEDURE traspaso_seguro(psseguro IN NUMBER,
                             pssegpol IN NUMBER,
                             mens     OUT VARCHAR2);

   PROCEDURE traspaso_tablas_seguros(psseguro IN NUMBER,
                                     mens     OUT VARCHAR2,
                                     programa IN VARCHAR2 DEFAULT 'ALCTR126',
                                     pcmotmov IN NUMBER DEFAULT NULL,
                                     pfecha   IN DATE DEFAULT NULL);

   FUNCTION f_borrar_tabla_estresulseg(psseguro IN NUMBER,
                                       pnmovimi IN NUMBER,
                                       pnriesgo IN NUMBER) RETURN NUMBER;

   PROCEDURE p_ins_estgar_invisibles(psseguro IN NUMBER,
                                     pnmovimi IN NUMBER,
                                     pfefecto IN DATE,
                                     mens     OUT VARCHAR2);

   PROCEDURE p_borrar_estprestamo(c_ctapres IN VARCHAR2);

   FUNCTION f_act_histom(pssegpol IN NUMBER,
                         psperson IN NUMBER,
                         pnmovimi IN NUMBER) RETURN NUMBER;

   FUNCTION f_act_hisaseg(pssegpol IN NUMBER,
                          psperson IN NUMBER,
                          pnmovimi IN NUMBER,
                          pnorden  IN NUMBER) -- BUG11183:DRA:08/10/2009
    RETURN NUMBER;

   FUNCTION f_act_hisriesgo(pssegpol IN NUMBER,
                            pnriesgo IN NUMBER,
                            pnmovimi IN NUMBER) RETURN NUMBER;

   PROCEDURE traspaso_tomadores(psseguro IN NUMBER,
                                pssegpol IN NUMBER,
                                pnmovimi IN NUMBER,
                                pmensaje OUT VARCHAR2);

   PROCEDURE traspaso_asegurados(psseguro IN NUMBER,
                                 pssegpol IN NUMBER,
                                 pnmovimi IN NUMBER,
                                 pmensaje OUT VARCHAR2);

   --JTS 17/12/2008 APRA 8467
   PROCEDURE traspaso_segcbancar(psseguro IN NUMBER,
                                 pssegpol IN NUMBER,
                                 pnmovimi IN NUMBER,
                                 mens     OUT VARCHAR2);

   PROCEDURE p_limpiar_tablas(psolicit IN NUMBER,
                              pnriesgo IN NUMBER,
                              pnmovimi IN NUMBER,
                              pcobjase IN NUMBER,
                              ppmode   IN VARCHAR2);

   PROCEDURE borrar_movimiento(psseguro IN NUMBER,
                               pnmovimi IN NUMBER,
                               pmovseg  IN NUMBER DEFAULT 0);

   /**********************************************************************
      Procedimiento de traspado iquilinos y avalistas de las tablas EST a las reales
        param psseguro IN NUMBER,
        param   pssegpol IN NUMBER,
        param  pnmovimi IN NUMBER,
        param  pfefecto  IN DATE,
       param  mens OUT VARCHAR2

   ***********************************************************************/
   --bug 21657--ETM--05/06/2012
   PROCEDURE p_traspaso_inquiaval(psseguro IN NUMBER,
                                  pssegpol IN NUMBER,
                                  pnmovimi IN NUMBER,
                                  pfefecto IN DATE,
                                  mens     OUT VARCHAR2);

   -- Bug 36596 IGIL INI
   PROCEDURE traspaso_citas(psseguro IN NUMBER,
                            pssegpol IN NUMBER,
                            pnmovimi IN NUMBER,
                            pmensaje OUT VARCHAR2);
   -- Bug 36596 IGIL FIN

   -- INI BUG 40927/228750 - 07/03/2016 - JAEG
   /*************************************************************************
      PROCEDURE p_traspaso_contgaran

      param in psseguro    : psseguro
      param in mensajes    : t_iax_mensajes
      return               : t_iax_contragaran
   *************************************************************************/
   PROCEDURE traspaso_contgaran(psseguro IN NUMBER,
                                pssegpol IN NUMBER,
                                pnmovimi IN NUMBER,
                                pmensaje OUT VARCHAR2);
   -- FIN BUG 40927/228750 - 07/03/2016 - JAEG

/**********************************************************************
Procedimiento de traspado iquilinos y avalistas de las tablas EST a las reales

***********************************************************************/
     FUNCTION F_ACT_HISPSU(psseguro  IN NUMBER, --ramiro
                           pnmovimi IN NUMBER)  --ramiro

      RETURN NUMBER; --ramiro
      
     PROCEDURE borrar_tablas(psseguro IN NUMBER);
END;

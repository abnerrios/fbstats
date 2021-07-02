import os, sys
import psycopg2 as pg

params = {
  'database': 'dbfoot',
  'user': 'postgres',
  'host': 'localhost',
  'password': 'c67HJD5'
}

class squad_service():
  def __main__(self):
    try:
      self.conn = pg.connect(**params)
    except (Exception, pg.DatabaseError):
      sys.exit()
  
  def insert_squad(self,squad):
    cur = self.conn.cursor()
    cur.execute('CALL p_upsert_squad(%s,%s);',squad)

  def insert_round(self,squad):
    cur = self.conn.cursor()
    cur.execute('CALL p_upsert_round(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s);',squad)

  def insert_ofensive_stats(self,squad):
    cur = self.conn.cursor()
    cur.execute('CALL p_upsert_squad_ofensive_stats(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s);',squad)
  
  def insert_defensive_stats(self,squad):
    cur = self.conn.cursor()
    cur.execute('CALL p_upsert_squad_defensive_stats(%s,%s);',squad)
  
  def insert_gk_stats(self,squad):
    cur = self.conn.cursor()
    cur.execute('CALL p_upsert_squad_gk_stats(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s);',squad)
  
  def insert_pass_stats(self,squad):
    cur = self.conn.cursor()
    cur.execute('CALL p_upsert_squad_pass_stats(%s,%s);',squad)

  def insert_possession_stats(self,squad):
    cur = self.conn.cursor()
    cur.execute('CALL p_upsert_squad_possession_stats(%s,%s);',squad)
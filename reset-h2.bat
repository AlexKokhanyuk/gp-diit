@echo off
cd /d "%~dp0"
if not exist data mkdir data
if exist data\deadlock-lab.mv.db (
  if exist data\deadlock-lab.mv.db.bak del /q data\deadlock-lab.mv.db.bak
  ren data\deadlock-lab.mv.db deadlock-lab.mv.db.bak
  echo H2 database moved to data\deadlock-lab.mv.db.bak
) else (
  echo H2 database file was not found.
)


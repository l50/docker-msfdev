echo POSTGRES_PW=\'$(perl -e 'print[0..9,a..z,A..Z]->[rand 62]for 1..10')\' >> env

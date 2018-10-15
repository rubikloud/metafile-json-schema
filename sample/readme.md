Metafile Generator Sample
-------------------------

RUNNING
=======

Given a folder with a number of comma separated value files in it;

 /data/tills/trx_2017_01_05_1109.aaa.csv
 /data/tills/trx_2017_01_05_1109.aab.csv
 /data/tills/trx_2017_01_05_1109.aac.csv
 /data/tills/trx_2017_01_05_1109.aad.csv

Generator can be called with these parameters;

 $ generate.sh TILLS /data/tills trx_2017_01_05_1109

and it will generate the following;

 /data/tills/trx_2017_01_05_1109.aaa.csv.gz
 /data/tills/trx_2017_01_05_1109.aab.csv.gz
 /data/tills/trx_2017_01_05_1109.aac.csv.gz
 /data/tills/trx_2017_01_05_1109.aad.csv.gz
 /data/tills/trx_2017_01_05_1109.meta.json

Which can then be uploaded to RubiKloud in that order

TESTING
=======

See generator.bats

LICENSE
=======

Copyright 2018 Rubikloud Technologies Inc

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

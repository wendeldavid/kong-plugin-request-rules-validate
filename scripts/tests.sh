#!/bin/bash

export POSTGRES_IMAGE=postgres:15
export KONG_VERSION=2.8.4
export KONG_LOG_LEVEL=debug

rm -f luacov.report.out
rm -f luacov.stats.out
rm -f output.xml

# all tests
pongo run -- --coverage --o junit >> output.xml 2>&1 || true
pongo down

end_line=$(grep -n "<testsuites" output.xml | cut -d: -f1)
end_line=$(echo $end_line | bc)
end_line=$((end_line - 1))

sed -i "1,${end_line}d" output.xml

grep "errors='0'" output.xml
c=$?

if [ $c -ne 0 ]
then
    echo "saiu no erro"
    exit 1
fi

grep "failures='0'" output.xml
c=$?
if [ $c -ne 0 ]; then
    echo "saiu no erro"
    exit 1
fi

echo "saiu no sucesso"

etadata :name => "nettest_mma",
        :description => "Max, min, average aggregate function.",
        :author => "P. Loubser <pieter.loubser@puppetlabs.com>",
        :license => "BSD",
        :version => "1.0.0",
        :url => "http://projects.puppetlabs.com/projects/mcollective-plugins/wiki",
        :timeout => 1

usage <<-END_OF_USAGE
Min, Max Average(Mma) Aggregate function is a numeric type function
that will consume numeric values and derive the minimum and maximum
values from the input set, as well as calculate the average value.

Aggregate formats should be in the style of "%s...%s...%s" as this
function returns a 3 element array to process in the result object.

Usage in DDL:
  aggregate nettest_mma(:myinput)

    would aggregate possible results in the format

  Min: 11.812  Max: 11.812  Average: 11.812
END_OF_USAGE

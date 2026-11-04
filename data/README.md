# Bundled `ehtplot` color tables

## Source and redistribution notice

The 182 `.ctab` files in this directory are **verbatim, unmodified
redistributions** of the tables in
[`ehtplot/color/ctabs/`](https://github.com/liamedeiros/ehtplot/tree/master/ehtplot/color/ctabs)
from [`liamedeiros/ehtplot`](https://github.com/liamedeiros/ehtplot). Credit
ehtplot and these source tables to **Chi-kwan Chan** and **Lia Medeiros**;
see the [ASCL record, ascl:2106.038](https://ascl.net/2106.038) and its ADS
bibcode [`2021ascl.soft06038C`](https://ui.adsabs.harvard.edu/abs/2021ascl.soft06038C/abstract).
Original filenames and table order are preserved. No table is generated,
interpolated, renamed, or otherwise altered by this package.

The upstream `ehtplot` project is distributed under the GNU General Public
License, version 3.0. A verbatim copy of its license text is included in this
directory as [`LICENSE-ehtplot-GPL-3.0.txt`](LICENSE-ehtplot-GPL-3.0.txt).
This notice and license copy must accompany redistribution of these tables.

## Use in this package

The package preserves every source filename, exposes its stem through
`scheme_names()` and `colorscheme`, and registers it in
`ColorSchemes.colorschemes`. It additionally creates an in-memory `r` reverse
for every bundled table; no duplicate `.ctab` file is added.

Each file contains 256 rows of three integer RGB channels. The package decodes
each channel by dividing by 1023, clips the result to `[0, 1]` as `ehtplot`
does, and preserves row order.

The package source is also distributed under GPL-3.0; see the
repository-level [`LICENSE`](../LICENSE).

let project_folder="static";//require('path').basename(__dirname);
let source_folder="src";
let { series, parallel } = require('gulp');
let build = parallel(html, css);
let watch = series(clean, build, parallel(watchFiles, browserSync));
let { src, dest } = require('gulp');
let	gulp = require('gulp');
let	browsersync = require("browser-sync").create();
let fileinclude = require("gulp-file-include");
let del = require('del');
let scss = require('gulp-sass')(require('sass'));
let autoprefixer = require('gulp-autoprefixer');
let clean_css = require('gulp-clean-css');
let rename = require('gulp-rename');
let imagemin = require('gulp-imagemin');
var exec = require('child_process').exec
// var concat = require('gulp-concat');

let path={
	build:{
		html: project_folder + "/",
		css: project_folder + "/css/",
		js: project_folder + "/js/",
		img: project_folder + "/img/",
		fonts: project_folder + "/fonts/",
		},
	src:{
		html: [source_folder + "/*.html", "!"+source_folder + "/_*.html"],
		css: source_folder + "/css/{normalize.sass,style.sass}",
		js: source_folder + "/js/script.js",
		img: source_folder + "/img/**/*.{jpg,png,svg,gif,ico,webp}",
		fonts: source_folder + "/fonts/*.ttf",
		},
	watch:{
		html: "./**/*.html",
		css: source_folder + "/css/**/*.{css,sass,scss}",
		js: source_folder + "/js/**/*.js",
		img: source_folder + "/img/**/*.{jpg,png,svg,gif,ico,webp}",
		},
	clean: "./" + project_folder + "/css/*"
	}

function browserSync() {
  runserver();
  browsersync.init({
  	injectChanges: true,
  	notify: true,
  	// open: false,
  	port:8000,
  	proxy: "127.0.0.1:8080"

  });
  
}

function runserver() {
  return exec('python manage.py runserver 8080');
}

function watchFiles(params) {
	gulp.watch([path.watch.html], build);
  	gulp.watch([path.watch.css], css);
  	// gulp.watch([path.watch.js], js);
  	// gulp.watch([path.watch.img], images);
}

function html(done) {
	browsersync.reload();
    done();
}

function css() {
	return gulp.src([//'src/css/normalize.sass',
                    'src/css/style.sass',
					// path.src.css
                    ])
            .pipe(fileinclude())
			// .pipe(concat('style.sass'))
			.pipe(
				scss({
					outputStyle: "expanded"
				}))
			.pipe(
				autoprefixer({
					overrideBrowserslist: ["last 15 versions"],
					cascade: true
				}))
			.pipe(dest(path.build.css))
			.pipe(clean_css())
			.pipe(
				rename({
					extname: ".min.css"
				}))
			.pipe(dest(path.build.css))
			.pipe(browsersync.stream())
}

// function js() {
// 	return gulp.src(path.src.js)
// 			.pipe(fileinclude())
// 			.pipe(dest(path.build.js))
// 			.pipe(
// 				uglify()
// 			)
// 			.pipe(
// 				rename({
// 					extname: ".min.js"
// 				}))
// 			.pipe(dest(path.build.js))
// 			.pipe(browsersync.stream())
// }

// function images() {
// 	return gulp.src(path.src.img)
// 			.pipe(
// 				webp({
// 					quality: 70
// 				}))
// 			.pipe(dest(path.build.img))
// 			.pipe(src(path.src.img))
// 			.pipe(
// 				imagemin({
// 					progressive: true,
// 					svgoPlugins: [{ removeViewBox: false }],
// 					interlaced: true,
// 					optimizationLevel: 3 //0 to 7
// 				})
// 			)
// 			.pipe(dest(path.build.img))
// 			.pipe(browsersync.stream())
// }

function clean(params) {
	return del(path.clean);
}

// exports.js = js;
exports.build = build;
exports.watch = watch;
exports.default = watch;

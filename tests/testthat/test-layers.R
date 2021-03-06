context("layers")

assets <- normalizePath(testthat::test_path("test-assets"), mustWork = TRUE)

blue <- list(color = "blue !default")
red <- list(color = "red !default")
green <- list(color = "green !default")
core <- sass_layer(
  defaults = blue,
  declarations = "@function my_invert($color, $amount: 100%) {
    $inverse: change-color($color, $hue: hue($color) + 180);
    @return mix($inverse, $color, $amount);
  }",
  rules = "body { background-color: $color; color: my_invert($color); }"
)

test_that("sass_layer is equivalent to sass", {
  expect_equivalent(
    sass(core),
    sass(list(blue, "body { background-color: $color; color: yellow; }"))
  )
})

test_that("sass_layer_merge() works as intended", {
  red_layer <- sass_layer(red, rules = ":root{ --color: #{$color}; }")
  expect_equivalent(
    sass(list(red, core, ":root{ --color: #{$color}; }")),
    sass(sass_layer_merge(core, red_layer))
  )
})

test_that("additional merging features", {
  layer1 <- sass_layer(
    file_attachments = c(
      file.path(assets, "a.txt")
    ),
    tags = c("tag1", "tag2")
  )

  layer2 <- sass_layer(
    file_attachments = c(
      "b/b1.txt" = file.path(assets, "b/b1.txt")
    ),
    tags = c("tag3")
  )

  layer_merged <- sass_layer_merge(layer1, layer2)
  expect_identical(
    layer_merged$file_attachments,
    c(
      file.path(assets, "a.txt"),
      "b/b1.txt" = file.path(assets, "b/b1.txt")
    )
  )
  expect_identical(
    layer_merged$tags,
    c("tag1", "tag2", "tag3")
  )
})

test_that("file attachments are written", {
  layer1 <- sass_layer(
    rules = "body { background-color: $body-bg; }",
    file_attachments = c(
      "assets/txt/a.txt" = file.path(assets, "a.txt")
    )
  )

  input <- list(
    list("body-bg" = "silver"),
    layer1
  )

  expect_error(
    sass(input, write_attachments = TRUE),
    "cannot be used when output=NULL"
  )

  expect_warning(sass(input), NA)

  tmpdir <- tempfile()
  stopifnot(nzchar(tmpdir)) # Precaution because we'll `rm -rf` this later
  on.exit(unlink(tmpdir, recursive = TRUE), add = TRUE)

  dir.create(tmpdir)

  sass(input,
    output = file.path(tmpdir, "styles.css"),
    write_attachments = TRUE)

  expect_true(
    file.exists(file.path(tmpdir, "assets/txt/a.txt"))
  )

  # the default for write_attachments warns if file attachments are present
  expect_warning(
    sass(input, output = file.path(tmpdir, "styles1.css")),
    "file attachments that are being ignored"
  )
  # when write_attachments = FALSE, the warning is suppressed
  expect_warning(
    sass(input, output = file.path(tmpdir, "styles1.css"), write_attachments = FALSE),
    NA
  )

})

test_that("write_file_attachments edge cases", {
  tmpdir <- tempfile()
  stopifnot(nzchar(tmpdir)) # Precaution because we'll `rm -rf` this later

  dir.create(tmpdir)
  oldwd <- getwd()
  setwd(tmpdir)
  on.exit({
    setwd(oldwd)
    unlink(tmpdir, recursive = TRUE)
  }, add = TRUE)

  # === Failures ===========

  dir.create("test0")

  # Relative dest path points upward
  expect_error(write_file_attachments(
    c("foo/../../bar" = file.path(assets, "a.txt")),
    output_path = "test0"
  ), "Illegal file attachment destination")

  # Relative source path not allowed
  expect_error(write_file_attachments(
    c("test0"),
    output_path = "test0"
  ), "must be absolute")

  # File attachment must exist
  expect_error(write_file_attachments(
    c("a.txt" = "/weflkjwkefjeg.txt"),
    output_path = "test0"
  ), "must exist")

  # === Successes ===========

  dir.create("test1")
  write_file_attachments(
    c(
      "files/A" = file.path(assets, "a.txt"),
      "files/B" = file.path(assets, "b/b1.txt"),
      "C" = file.path(assets, "c")
    ),
    "test1"
  )
  expect_identical(
    sort(list.files("test1", all.files = TRUE, recursive = TRUE)),
    c("C/c1.txt", "C/d/d1.txt", "files/A", "files/B")
  )

  dir.create("test2")
  write_file_attachments(
    c(
      "a1" = file.path(assets, "a.txt"),
      "a2/" = file.path(assets, "a.txt"),
      file.path(assets, "b"),
      "c1/" = file.path(assets, "c"),
      "c2" = file.path(assets, "c"),
      "c3/" = file.path(assets, "c/"),
      "c4" = file.path(assets, "c/")
    ),
    "test2"
  )
  expect_identical(
    sort(list.files("test2", all.files = TRUE, recursive = TRUE)),
    c(
      "a1",
      "a2/a.txt",
      "b1.txt",
      "c1/c1.txt", "c1/d/d1.txt",
      "c2/c1.txt", "c2/d/d1.txt",
      "c3/c1.txt", "c3/d/d1.txt",
      "c4/c1.txt", "c4/d/d1.txt"
    )
  )
})

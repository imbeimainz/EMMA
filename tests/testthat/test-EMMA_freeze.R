test_that("EMMA_freeze", {
  
  tmp <- tempfile("emma_env")
  dir.create(tmp)
  
  lockfile <- file.path(tmp, "renv.lock")
  
  res_path <- EMMA_freeze(
    project = tmp,
    file = "renv.lock",
    pkgs = "stats",
    prompt = TRUE,
    force = TRUE
  )
  
  expect_true(dir.exists(tmp))
  
  expect_true(file.exists(lockfile))
  
  expect_identical(res_path, lockfile)
  
  expect_error(EMMA_freeze(project = 2))
  
  expect_error(EMMA_freeze(file = NULL))
  
  expect_error(EMMA_freeze(file = NA_character_))
  
  expect_error(EMMA_freeze(pkgs = 1:3))
  
  expect_error(EMMA_freeze(promt = "no"))
  
  expect_error(EMMA_freeze(force = "yes"))
    
})

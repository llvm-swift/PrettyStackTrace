// RUN: cat %S/../Sources/PrettyStackTrace/PrettyStackTrace.swift %s | swiftc -c -emit-executable -o %t - && %t 2>&1 | %FileCheck %s

// CHECK-DAG: Stack dump
// CHECK-DAG:  1. While in frame 100
// CHECK-DAG:  2. While in frame 99
// CHECK-DAG:  3. While in frame 98
// CHECK-DAG:  4. While in frame 97
// CHECK-DAG:  5. While in frame 96
// CHECK-DAG:  6. While in frame 95
// CHECK-DAG:  7. While in frame 94
// CHECK-DAG:  8. While in frame 93
// CHECK-DAG:  9. While in frame 92
// CHECK-DAG:  10. While in frame 91
// CHECK-DAG:  11. While in frame 90
// CHECK-DAG:  12. While in frame 89
// CHECK-DAG:  13. While in frame 88
// CHECK-DAG:  14. While in frame 87
// CHECK-DAG:  15. While in frame 86
// CHECK-DAG:  16. While in frame 85
// CHECK-DAG:  17. While in frame 84
// CHECK-DAG:  18. While in frame 83
// CHECK-DAG:  19. While in frame 82
// CHECK-DAG:  20. While in frame 81
// CHECK-DAG:  21. While in frame 80
// CHECK-DAG:  22. While in frame 79
// CHECK-DAG:  23. While in frame 78
// CHECK-DAG:  24. While in frame 77
// CHECK-DAG:  25. While in frame 76
// CHECK-DAG:  26. While in frame 75
// CHECK-DAG:  27. While in frame 74
// CHECK-DAG:  28. While in frame 73
// CHECK-DAG:  29. While in frame 72
// CHECK-DAG:  30. While in frame 71
// CHECK-DAG:  31. While in frame 70
// CHECK-DAG:  32. While in frame 69
// CHECK-DAG:  33. While in frame 68
// CHECK-DAG:  34. While in frame 67
// CHECK-DAG:  35. While in frame 66
// CHECK-DAG:  36. While in frame 65
// CHECK-DAG:  37. While in frame 64
// CHECK-DAG:  38. While in frame 63
// CHECK-DAG:  39. While in frame 62
// CHECK-DAG:  40. While in frame 61
// CHECK-DAG:  41. While in frame 60
// CHECK-DAG:  42. While in frame 59
// CHECK-DAG:  43. While in frame 58
// CHECK-DAG:  44. While in frame 57
// CHECK-DAG:  45. While in frame 56
// CHECK-DAG:  46. While in frame 55
// CHECK-DAG:  47. While in frame 54
// CHECK-DAG:  48. While in frame 53
// CHECK-DAG:  49. While in frame 52
// CHECK-DAG:  50. While in frame 51
// CHECK-DAG:  51. While in frame 50
// CHECK-DAG:  52. While in frame 49
// CHECK-DAG:  53. While in frame 48
// CHECK-DAG:  54. While in frame 47
// CHECK-DAG:  55. While in frame 46
// CHECK-DAG:  56. While in frame 45
// CHECK-DAG:  57. While in frame 44
// CHECK-DAG:  58. While in frame 43
// CHECK-DAG:  59. While in frame 42
// CHECK-DAG:  60. While in frame 41
// CHECK-DAG:  61. While in frame 40
// CHECK-DAG:  62. While in frame 39
// CHECK-DAG:  63. While in frame 38
// CHECK-DAG:  64. While in frame 37
// CHECK-DAG:  65. While in frame 36
// CHECK-DAG:  66. While in frame 35
// CHECK-DAG:  67. While in frame 34
// CHECK-DAG:  68. While in frame 33
// CHECK-DAG:  69. While in frame 32
// CHECK-DAG:  70. While in frame 31
// CHECK-DAG:  71. While in frame 30
// CHECK-DAG:  72. While in frame 29
// CHECK-DAG:  73. While in frame 28
// CHECK-DAG:  74. While in frame 27
// CHECK-DAG:  75. While in frame 26
// CHECK-DAG:  76. While in frame 25
// CHECK-DAG:  77. While in frame 24
// CHECK-DAG:  78. While in frame 23
// CHECK-DAG:  79. While in frame 22
// CHECK-DAG:  80. While in frame 21
// CHECK-DAG:  81. While in frame 20
// CHECK-DAG:  82. While in frame 19
// CHECK-DAG:  83. While in frame 18
// CHECK-DAG:  84. While in frame 17
// CHECK-DAG:  85. While in frame 16
// CHECK-DAG:  86. While in frame 15
// CHECK-DAG:  87. While in frame 14
// CHECK-DAG:  88. While in frame 13
// CHECK-DAG:  89. While in frame 12
// CHECK-DAG:  90. While in frame 11
// CHECK-DAG:  91. While in frame 10
// CHECK-DAG:  92. While in frame 9
// CHECK-DAG:  93. While in frame 8
// CHECK-DAG:  94. While in frame 7
// CHECK-DAG:  95. While in frame 6
// CHECK-DAG:  96. While in frame 5
// CHECK-DAG:  97. While in frame 4
// CHECK-DAG:  98. While in frame 3
// CHECK-DAG:  99. While in frame 2
// CHECK-DAG:  100. While in frame 1
func buildTrace(_ int: Int = 1) {
  if int > 100 { abort() }
  trace("in frame \(int)") {
    buildTrace(int + 1)
  }
}

buildTrace()
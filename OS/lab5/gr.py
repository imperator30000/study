import psutil
import matplotlib.pyplot as plt
import time

times = []
free_memory = []
swap_size = []

start_time = time.time()
koef = 100
cnt = 5 * koef
term = False
for _ in range(120 * koef):
    if term:
        cnt -= 1
    current_time = time.time() - start_time
    mem = psutil.virtual_memory()
    swap = psutil.swap_memory()

    times.append(current_time)
    free_memory.append(mem.free)
    swap_size.append(swap.used)
    if swap.free < 10 * 1024 * 1024:
        term = True
    time.sleep(1 / koef)
    if cnt == 0:
        break


plt.figure(figsize=(10, 5))


plt.plot(times, free_memory, label='Free Memory')


plt.plot(times, swap_size, label='Swap Size')



plt.legend()


plt.savefig('memory_and_swap.png')

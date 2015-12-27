import time

DEFAULT_STEP = 100


class ProgressDisplay(object):

	def __init__(self, total, step=DEFAULT_STEP):
		self.t0 = time.time()
		self.completed = 0
		self.total = total
		self.step = step
		self.last_checkpoint = 0

	def advance(self, d=1):
		self.completed+= d
		if self.completed - self.last_checkpoint >= self.step:
			self.last_checkpoint = self.completed

			elapsed = time.time() - self.t0
			time_per_item = float(elapsed) / float(self.completed)
			percent_completed = float(self.completed) / float(self.total) * 100.
			time_remaining = int(float(time_per_item) * float(self.total - self.completed) / 60)
			print "%.2f%% completed (%d/%d), estimated %d minutes remaining, %.4f sec per event" % (percent_completed,
				self.completed, self.total, time_remaining, time_per_item)
